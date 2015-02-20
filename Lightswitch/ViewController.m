//
//  ViewController.m
//  Lightswitch
//
//  Created by Chris Slowik on 2/19/15.
//  Copyright (c) 2015 Chris Slowik. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ESTBeaconManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup estimote beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create region object
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"9447A2E0CB4609DBd1B1A02C0821"] identifier:@"office"];
    
    [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:region];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
