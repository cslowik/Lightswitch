//
//  ViewController.m
//  Lightswitch
//
//  Created by Chris Slowik on 2/19/15.
//  Copyright (c) 2015 Chris Slowik. All rights reserved.
//

#import "ViewController.h"

#define kUnknownDistance    @"Searching.."
#define kImmediateDistance  @"Immediate"
#define kNearDistance       @"Near"
#define kFarDistance        @"Far"

@interface ViewController () <ESTBeaconManagerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *measureLabel;

@property (assign, nonatomic) BOOL wasImmediate;

//@property (strong, nonatomic) PHHueSDK *hueManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSUserDefaults *prefs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.prefs = [NSUserDefaults standardUserDefaults];
    
    self.wasImmediate = NO;
    
    // setup location manager
    self.locationManager = [CLLocationManager new];
    
    // initialize locationManager
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // if its ios8
    if ( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // setup estimote beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create region object
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] identifier:@"estimotes"];
    
    // start ranging existing beacons
    [self.beaconManager startRangingBeaconsInRegion:region];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ESTBeaconManagerDelegate

- (void) beaconManager:(ESTBeaconManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(ESTBeaconRegion *)region {
    NSLog(@"RANGING");
    if (beacons.count > 0) {
        // beacon array is sorted based on distance
        // closest beacon is the first one
        ESTBeacon *closestBeacon = beacons[0];
        
        CGFloat distance = [closestBeacon.distance floatValue];
        
        // set distance
        switch (closestBeacon.proximity) {
            case CLProximityUnknown:
            {
                self.distanceLabel.text = kUnknownDistance;
                self.measureLabel.text = [NSString stringWithFormat:@"%fm", distance];
                self.wasImmediate = NO;
            }
                break;
                
            case CLProximityImmediate:
            {
                self.distanceLabel.text = kImmediateDistance;
                self.measureLabel.text = [NSString stringWithFormat:@"%fm", distance];
                if (!self.wasImmediate) {
                    self.wasImmediate = YES;
                    [self allOn];
                }
            }
                break;
                
            case CLProximityNear:
            {
                self.distanceLabel.text = kNearDistance;
                self.measureLabel.text = [NSString stringWithFormat:@"%fm", distance];
                self.wasImmediate = NO;
            }
                break;
                
            case CLProximityFar:
            {
                self.distanceLabel.text = kFarDistance;
                self.measureLabel.text = [NSString stringWithFormat:@"%fm", distance];
                self.wasImmediate = NO;
                [self allOff];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - lighting functions

- (void)allOn {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:[self.prefs objectForKey:@"HueHostPrefKey"] username:[self.prefs objectForKey:@"HueAPIUsernamePrefKey"]];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        [hue allLightsOn];
    }];
}

- (void)allOff {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:[self.prefs objectForKey:@"HueHostPrefKey"] username:[self.prefs objectForKey:@"HueAPIUsernamePrefKey"]];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        [hue allLightsOff];
    }];
}

@end
