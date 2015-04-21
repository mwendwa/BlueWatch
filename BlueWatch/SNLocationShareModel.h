//
//  LocationShareModel.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNBackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SNLocationShareModel : NSObject

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) SNBackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;
@property (nonatomic) CLLocation *myLocation;

+ (id) sharedModel;

@end
