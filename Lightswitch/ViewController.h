//
//  ViewController.h
//  Lightswitch
//
//  Created by Chris Slowik on 2/19/15.
//  Copyright (c) 2015 Chris Slowik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/ESTBeaconManager.h>
#import <CoreLocation/CoreLocation.h>
#import <DPHue/DPHue.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) ESTBeaconManager *beaconManager;

@end

