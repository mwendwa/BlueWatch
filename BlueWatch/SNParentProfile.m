//
//  SNParentProfile.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 12/16/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNParentProfile.h"

#define kName   @"name"
#define kNumber @"number"
#define kEmail  @"email"

@implementation SNParentProfile

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.number forKey:kNumber];
    [encoder encodeObject:self.email forKey:kEmail];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name   = [decoder decodeObjectForKey:kName];
        self.number = [decoder decodeObjectForKey:kNumber];
        self.email  = [decoder decodeObjectForKey:kEmail];
    }
    
    return self;
}

#pragma mark - Save

- (void)save:(NSString *)keyName {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:keyName];
    [defaults synchronize];
}

+ (SNParentProfile *)savedParent:(NSString *)keyName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:keyName];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Name: %@, Number: %@, E-Mail: %@>",
            self.name, self.number, self.email];
}

@end
