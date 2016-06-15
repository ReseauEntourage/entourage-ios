//
//  OTLocationManager.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationLocationUpdated @"NotificationLocationUpdated"
#define kNotificationLocationUpdatedInfoKey @"NotificationLocationUpdatedInfoKey"

#define kNotificationLocationAuthorizationChanged @"NotificationLocationAuthorizationChanged"
#define kNotificationLocationAuthorizationChangedKey @"NotificationLocationAuthorizationChangedKey"

@interface OTLocationManager : NSObject

+(OTLocationManager *)sharedInstance;

- (void)startLocationUpdates;

@end
