//
//  NSNotification+entourage.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "NSNotification+entourage.h"
#import "OTLocationManager.h"

@implementation NSNotification (entourage)

- (NSArray *)readLocations {
    return [self.userInfo objectForKey:kNotificationLocationUpdatedInfoKey];
}

- (BOOL)readAuthorizationAllowed {
    return [(NSNumber *)[self.userInfo objectForKey:kNotificationLocationAuthorizationChangedKey] boolValue];
}

@end
