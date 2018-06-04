//
//  OTPushNotificationsService.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APNOTIFICATION_CHAT_MESSAGE "NEW_CHAT_MESSAGE"
#define APNOTIFICATION_JOIN_REQUEST "NEW_JOIN_REQUEST"
#define APNOTIFICATION_REQUEST_ACCEPTED "JOIN_REQUEST_ACCEPTED"
#define APNOTIFICATION_INVITE_REQUEST "ENTOURAGE_INVITATION"
#define APNOTIFICATION_INVITE_STATUS "INVITATION_STATUS"
#define APNOTIFICATION_JOIN_REQUEST_CANCELED "JOIN_REQUEST_CANCELED"
#define APNOTIFICATION_MIXPANEL_DEEPLINK "mp_cta"

@interface OTPushNotificationsService : NSObject

- (void)sendAppInfo;
- (void)saveToken:(NSData *)tokenData;
- (void)promptUserForPushNotifications;
- (void)clearTokenWithSuccess:(void (^)(void))success orFailure:(void (^)(NSError*))failure;
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (void)handleLocalNotification:(NSDictionary *)userInfo;

- (BOOL)isMixpanelDeepLinkNotification:(NSDictionary *)userInfo;

@end
