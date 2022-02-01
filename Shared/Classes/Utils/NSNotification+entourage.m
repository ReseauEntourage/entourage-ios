//
//  NSNotification+entourage.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "NSNotification+entourage.h"
#import "OTLocationManager.h"
#import "OTConsts.h"
#import "OTEditEncounterBehavior.h"

@implementation NSNotification (entourage)

- (NSArray *)readLocations {
    return [self.userInfo objectForKey:kNotificationLocationUpdatedInfoKey];
}

- (BOOL)readAllowedLocation {
    return [(NSNumber *)[self.userInfo objectForKey:kNotificationLocationAuthorizationChangedKey] boolValue];
}

- (OTEncounter *)readEncounter {
    return [self.userInfo objectForKey:kNotificationEncounterEditedInfoKey];
}

@end
