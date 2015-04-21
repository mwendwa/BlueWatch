//
//  LocationShareModel.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import "SNLocationShareModel.h"

@implementation SNLocationShareModel

//Class method to make sure the share model is synch across the app
+ (id) sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}


@end
