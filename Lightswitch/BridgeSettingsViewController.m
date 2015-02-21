//
//  BridgeSettingsViewController.m
//  Lightswitch
//
//  Created by Chris Slowik on 2/21/15.
//  Copyright (c) 2015 Chris Slowik. All rights reserved.
//

#import "BridgeSettingsViewController.h"

@interface BridgeSettingsViewController ()

@property (nonatomic, strong) DPHueDiscover *dhd;
@property (nonatomic, strong) NSMutableString *discoveryLog;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *foundHueHost;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *discoveryProgressIndicator;
@property (weak, nonatomic) IBOutlet UILabel *discoveryStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *discoverySaveButton;
@property (weak, nonatomic) IBOutlet UILabel *hueBridgeLabel;

@property (strong, nonatomic) NSUserDefaults *prefs;

@end

@implementation BridgeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // shortcuts
    self.prefs = [NSUserDefaults standardUserDefaults];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)discoveryTimeHasElapsed {
     self.dhd = nil;
     [self.timer invalidate];
     [self.discoveryProgressIndicator stopAnimating];
     if (!self.foundHueHost) {
         self.discoveryStatusLabel.text = @"Failed to find Hue";
     }
 }

#pragma mark - IBActions
- (IBAction)didPressBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressSaveButton:(id)sender {
    NSLog(@"Saving %@", self.foundHueHost);
    [self.prefs setObject:self.foundHueHost forKey:@"HueHostPrefKey"];
    [self.prefs synchronize];
    self.hueBridgeLabel.text = self.foundHueHost;
    [self.dhd stopDiscovery];
    self.dhd = nil;
}

- (IBAction)didPressDiscoverButton:(id)sender {
    self.dhd = [[DPHueDiscover alloc] initWithDelegate:self];
    [self.dhd discoverForDuration:30 withCompletion:^(NSMutableString *log) {
        self.discoveryLog = log;
        [self discoveryTimeHasElapsed];
    }];
    [self.discoveryProgressIndicator startAnimating];
    self.discoveryStatusLabel.text = @"Searching for Hue...";
}

- (void)createUsernameAt:(NSTimer *)timer {
    NSString *host = timer.userInfo;
    NSLog(@"Attempting to create username at %@", host);
    [self.discoveryLog appendFormat:@"%@: Attempting to authenticate to %@\n", [NSDate date], host];
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:[[NSUserDefaults standardUserDefaults] objectForKey:@"HueAPIUsernamePrefKey"]];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        if (hue.authenticated) {
            [self.discoveryLog appendFormat:@"%@: Successfully authenticated\n", [NSDate date]];
            [self.timer invalidate];
            [self.discoveryProgressIndicator stopAnimating];
            [self.discoverySaveButton setEnabled:YES];
            self.foundHueHost = hue.host;
            self.discoveryStatusLabel.text = [NSString stringWithFormat:@"Found Hue named '%@'!", hue.name];
        } else {
            [self.discoveryLog appendFormat:@"%@: Authentication failed, will try to create username\n", [NSDate date]];
            [someHue registerUsername];
            self.discoveryStatusLabel.text = @"Press Button On Hue!";
        }
    }];
}

#pragma mark - DPHueDiscover delegate

- (void)foundHueAt:(NSString *)host discoveryLog:(NSMutableString *)log {
    self.discoveryLog = log;
    [self.discoveryProgressIndicator startAnimating];
    [self.discoverySaveButton setEnabled:NO];
    self.discoveryStatusLabel.text = @"Hue Found! Authenticating...";
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:[self.prefs objectForKey:@"HueAPIUsernamePrefKey"]];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(createUsernameAt:) userInfo:host repeats:YES];
    }];
}

@end
