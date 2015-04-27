//
//  AppDelegate.h
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 11/14/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLocationTracker.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SNLocationTracker *locationTracker;
@property (nonatomic) NSTimer *locationUpdateTimer;

@end

