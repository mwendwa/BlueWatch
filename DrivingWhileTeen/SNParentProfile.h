//
//  SNParentProfile.h
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 12/16/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNParentProfile : NSObject <NSCoding>

@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* number;
@property (copy, nonatomic) NSString* email;

- (void) save:(NSString *)keyName;
+ (SNParentProfile *) savedParent:(NSString *)keyName;
- (NSString *) description;

@end;
