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

@property (strong, nonatomic) PHHueSDK *hueManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.wasImmediate = NO;
    
    // Create sdk instance
    self.hueManager = [[PHHueSDK alloc] init];
    [self.hueManager startUpSDK];
    [self.hueManager enableLogging:YES];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    /***************************************************
     The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed
     by the bridge into the Bridge Resources Cache
     *****************************************************/
    
    [self enableLocalHeartbeat];
    
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
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Beacon Found" message:@"You found the Icy Marshmallow!" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertVC animated:YES completion:nil];
                    self.wasImmediate = YES;
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
            }
                break;
                
            default:
                break;
        }
    }
}

@end
