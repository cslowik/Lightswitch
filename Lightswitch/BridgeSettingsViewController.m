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

@end

@implementation BridgeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)didPressDiscoverButton:(id)sender {
    self.dhd = [[DPHueDiscover alloc] initWithDelegate:self];
    [self.dhd discoverForDuration:30 withCompletion:^(NSMutableString *log) {
        self.discoveryLog = log;
        [self discoveryTimeHasElapsed];
    }];
    [self.discoveryProgressIndicator startAnimating];
    self.discoveryStatusLabel.text = @"Searching for Hue...";
}

@end
