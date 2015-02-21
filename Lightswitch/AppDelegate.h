//
//  AppDelegate.h
//  Lightswitch
//
//  Created by Chris Slowik on 2/19/15.
//  Copyright (c) 2015 Chris Slowik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/ESTBeaconManager.h>
#import <EstimoteSDK/ESTConfig.h>
#import <DPHue/DPHueDiscover.h>
#import <DPHue/DPHue.h>
#import <DPHue/DPHueLight.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DPHueDiscoverDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

