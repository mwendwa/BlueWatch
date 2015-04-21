//
//  SNTeenProfile.h
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 12/29/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SNTeenProfile : NSObject <NSCoding>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *number;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) CLLocation *location;
@property (copy, nonatomic) NSArray *address;

- (void) save;
+ (SNTeenProfile *) savedTeen;
- (NSString *) description;
- (NSString *) myLocation;

@end
