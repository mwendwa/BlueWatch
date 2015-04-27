//
//  SNTeenProfile.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 12/29/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNTeenProfile.h"

@implementation SNTeenProfile

#define kName   @"name"
#define kNumber @"number"
#define kEmail  @"email"
#define kLocation @"location"
#define kAddress @"address"
#define kSavedTeen @"SavedTeen"

- (void)encodeWithCoder:(NSCoder *)encoder
{
    
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.number forKey:kNumber];
    [encoder encodeObject:self.email forKey:kEmail];
    [encoder encodeObject:self.location forKey:kLocation];
    [encoder encodeObject:self.address forKey:kAddress];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.name   = [decoder decodeObjectForKey:kName];
        self.number = [decoder decodeObjectForKey:kNumber];
        self.email  = [decoder decodeObjectForKey:kEmail];
        self.location = [decoder decodeObjectForKey:kLocation];
        self.address = [decoder decodeObjectForKey:kAddress];
    }
    
    return self;
}

#pragma mark - Save

- (void)save
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:kSavedTeen];
    [defaults synchronize];
}

+ (SNTeenProfile *)savedTeen
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kSavedTeen];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark - Description and Location

-(NSString *)description
{
    return [NSString stringWithFormat:@"<Name: %@, Number: %@, E-Mail: %@, Latitude %+.6f, Longitude %+.6f>",
            self.name, self.number, self.email, self.location.coordinate.latitude, self.location.coordinate.longitude];
}

-(NSString *)myLocation
{
    return [[self.address valueForKey:@"description"] componentsJoinedByString:@""];
}

@end
