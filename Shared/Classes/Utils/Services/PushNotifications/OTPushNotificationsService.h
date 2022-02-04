//
//  OTPushNotificationsService.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 Entourage. All rights reserved.
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

- (void)handleRemoteNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)appState;
- (void)handleLocalNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)appState;

- (BOOL)isMixpanelDeepLinkNotification:(NSDictionary *)userInfo;

+ (void)requestProvisionalAuthorizationsIfAdequate;
+ (void)promptUserForAuthorizationsWithCompletionHandler:(void (^)(void))completionHandler;
+ (void)getAuthorizationStatusWithCompletionHandler:(void (^)(UNAuthorizationStatus status))completionHandler;
+ (void)refreshPushToken;
+ (void)refreshPushTokenIfConfigurationChanged;
+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)legacyAuthorizationRequestCompletedWithError:(NSError * _Nullable)error;
@end
