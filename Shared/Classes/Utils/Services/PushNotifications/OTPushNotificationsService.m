//
//  OTPushNotificationsService.m
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>

#import "OTPushNotificationsService.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAuthService.h"
#import "OTConsts.h"
#import "OTActiveFeedItemViewController.h"
#import "OTMainViewController.h"
#import "UIStoryboard+entourage.h"
#import "OTFeedItemJoiner.h"
#import "OTFeedItemFactory.h"
#import "OTPushNotificationsData.h"
#import "OTDeepLinkService.h"
#import "OTEntourageInvitation.h"
#import "OTInvitationsService.h"
#import "OTUnreadMessagesService.h"
#import "OTAppState.h"
#import "OTAppDelegate.h"

static NSString *const kLegacyDidRegisterUserNotificationSettings = @"legacyDidRegisterUserNotificationSettings";
static NSString *const kRemoteNotificationsConfigurationDigest = @"remoteNotificationsConfigurationDigest";

@implementation OTPushNotificationsService

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [self setupObservers];
    return self;
}


#pragma mark - Observers

- (void)setupObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(currentUserUpdated:)
                   name:[kNotificationCurrentUserUpdated copy]
                 object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)currentUserUpdated:(NSNotification *)userUpdate {
    OTUser *previousUser;
    OTUser *currentUser;
    
    if (userUpdate.userInfo[@"previousValue"] == [NSNull null]) {
        previousUser = nil;
    } else {
        previousUser = userUpdate.userInfo[@"previousValue"];
    }
    
    if (userUpdate.userInfo[@"currentValue"] == [NSNull null]) {
        currentUser = nil;
    } else {
        currentUser = userUpdate.userInfo[@"currentValue"];
    }
    
    if (currentUser == nil && previousUser != nil) {
        [self clearTokenWithWithUser:previousUser];
    }
    else if (![currentUser.uuid isEqualToString:previousUser.uuid]) {
        [OTPushNotificationsService refreshPushToken];
    }
}


#pragma mark - Notification Options

+ (UNAuthorizationOptions)authorizationOptions {
    return (UNAuthorizationOptionBadge +
            UNAuthorizationOptionSound +
            UNAuthorizationOptionAlert);
}


#pragma mark - Main methods

// only request provisional authorization if iOS >= 12 and current authorization status is NotDetermined
+ (void)requestProvisionalAuthorizationsIfAdequate {
    if (@available(iOS 12.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                [self requestProvisionalAuthorizations];
            }
        }];
    }
}

+ (void)requestProvisionalAuthorizations {
    if (@available(iOS 12.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:([self authorizationOptions] + UNAuthorizationOptionProvisional)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  [self authorizationRequestGranted:granted withError:error];
                              }];
    }
}

static void (^legacyRequestAuthorizationCompletionHandler)(void);

+ (void)promptUserForAuthorizationsWithCompletionHandler:(void (^)(void))completionHandler {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:[self authorizationOptions]
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  [self authorizationRequestGranted:granted withError:error];
                                  completionHandler();
                              }];
    } else {
        // iOS 9 fallback
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeBadge +
                                                        UIUserNotificationTypeSound +
                                                        UIUserNotificationTypeAlert);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        
        legacyRequestAuthorizationCompletionHandler = completionHandler;
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // -> application:didRegisterUserNotificationSettings:
        //    -> legacyRequestAuthorizationCompletedWithError
    }
}

// iOS 9 fallback for promptUserForAuthorizationsWithCompletionHandler
+ (void)legacyAuthorizationRequestCompletedWithError:(NSError * _Nullable)error {
    if (@available(iOS 10.0, *)) {
        return;
    }
    
    BOOL granted;
    
    if (error) {
        granted = NO;
    } else {
        // used to differentiate NotDetermined and Denied in getAuthorizationStatusWithCompletionHandler
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLegacyDidRegisterUserNotificationSettings];
        
        UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
        granted = settings.types != UIUserNotificationTypeNone;
    }
    
    [self authorizationRequestGranted:granted withError:error];

    legacyRequestAuthorizationCompletionHandler();
    legacyRequestAuthorizationCompletionHandler = nil;
}

+ (void)authorizationRequestGranted:(BOOL)granted withError:(NSError * _Nullable)error {
    if (error == nil) {
        [self refreshPushToken];
    }
}

+ (void)refreshPushToken {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    });
    // -> applicationDidRegisterForRemoteNotificationsWithDeviceToken:
    // or
    // -> application:didFailToRegisterForRemoteNotificationsWithError:
}

+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    @try {
        [self saveToken:deviceToken];
    }
    @catch (NSException *ex) {
        
    }
}

+ (void)saveToken:(NSData *)tokenData {
    NSString *token = [self hexStringForDeviceToken:tokenData];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        [self sendPushToken:token];
    }
}

+ (void)sendPushToken:(NSString *)pushToken {
    [self getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        [OTAuthService sendAppInfoWithPushToken:pushToken
                            authorizationStatus:[self authorizationStatus:status]
                                        success:^{
                                            [self storeConfigurationDigestWithStatus:status];
                                        }
                                        failure:nil];
    }];
}

- (void)clearTokenWithWithUser:(OTUser *)previousUser {
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    [[OTAuthService new] deletePushToken:pushToken forUser:previousUser];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)getAuthorizationStatusWithCompletionHandler:(void (^)(UNAuthorizationStatus status))completionHandler {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            completionHandler(settings.authorizationStatus);
        }];
    } else {
        // iOS 9 fallback
        UNAuthorizationStatus status;
        UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
        if (settings.types == UIUserNotificationTypeNone) {
            // set in legacyAuthorizationRequestCompletedWithError
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kLegacyDidRegisterUserNotificationSettings]) {
                status = UNAuthorizationStatusDenied;
            } else {
                status = UNAuthorizationStatusNotDetermined;
            }
        } else {
            status = UNAuthorizationStatusAuthorized;
        }
        completionHandler(status);
    }
}


#pragma mark - Helper methods

+ (NSString *)hexStringForDeviceToken:(NSData *)deviceToken {
    const unsigned char *bytes = (const unsigned char*)deviceToken.bytes;
    NSMutableString *hexToken = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
    
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [hexToken appendFormat:@"%02x", bytes[i]];
    }
    
    return [hexToken copy];
}

+ (NSString *)authorizationStatus:(UNAuthorizationStatus)status {
    NSString *string;
    
    if (status == UNAuthorizationStatusNotDetermined) string = @"not_determined";
    if (status == UNAuthorizationStatusDenied)        string = @"denied";
    if (status == UNAuthorizationStatusAuthorized)    string = @"authorized";
    if (@available(iOS 12.0, *)) {
        if (status == UNAuthorizationStatusProvisional) string = @"provisional";
    }
    
    return string;
}

+ (void)storeConfigurationDigestWithStatus:(UNAuthorizationStatus)status {
    [[NSUserDefaults standardUserDefaults] setInteger:[self configurationDigestForStatus:status] forKey:kRemoteNotificationsConfigurationDigest];
}

+ (NSUInteger)configurationDigestForStatus:(UNAuthorizationStatus)status {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    NSString *uuid = currentUser.uuid;
    if (uuid == nil) uuid = @"";
    
    NSString *authorizationStatus = [self authorizationStatus:status];
    
    return [[@[date, uuid, authorizationStatus] componentsJoinedByString:@":"] hash];
}

+ (void)refreshPushTokenIfConfigurationChanged {
    [self getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        NSUInteger previousConfiguration = [[NSUserDefaults standardUserDefaults] integerForKey:kRemoteNotificationsConfigurationDigest];
        NSUInteger currentConfiguration = [self configurationDigestForStatus:status];
        
        if (currentConfiguration != previousConfiguration) {
            [self refreshPushToken];
        }
    }];
}


#pragma mark - Notifications handling

- (void)handleRemoteNotification:(NSDictionary *)userInfo
                applicationState:(UIApplicationState)appState {
    
    NSNumber *badge = [userInfo numberForKey:@"badge"];
    if (badge) {
        [[OTUnreadMessagesService sharedInstance] setTotalUnreadCount:badge];
    }

    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST]) {
        [self handleJoinRequestNotification:pnData];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST_CANCELED]) {
        [self handleCancelJoinNotification:pnData];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_REQUEST_ACCEPTED]) {
        [self handleAcceptJoinNotification:pnData applicationState:appState];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_CHAT_MESSAGE]) {
        if ([self canHandleChatNotificationInPlace:pnData]) {
            return;
        }
        else {
            [self handleChatNotification:pnData applicationState:appState];
        }
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_REQUEST]) {
        [self handleInviteRequestNotification:pnData];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_STATUS]) {
        [self handleInviteStatusNotification:pnData];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_MIXPANEL_DEEPLINK]) {
        [self handleMixpanelDeepLinkNotification:pnData];
    }
}

- (void)handleLocalNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)appState {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    
    if ([pnData.sender isEqualToString:@""]) {
        pnData.sender = pnData.message;
        pnData.message = @"";
    }
    
    if (appState != UIApplicationStateActive) {
        // https://jira.mytkw.com/browse/EMA-2229
        [OTAppState switchToMainScreenAndResetAppWindow:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationLocalTourConfirmation object:nil];
        
    }
//    else {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:pnData.sender
//                                                                       message:pnData.message
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
//
//        UIAlertAction *openAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            [OTAppState switchToMainScreenAndResetAppWindow:YES];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationLocalTourConfirmation object:nil];
//        }];
//
//        [alert addAction:defaultAction];
//        [alert addAction:openAction];
//
//        [self showAlert:alert withPresentingBlock:^(UIViewController *topController, UIViewController *presentedViewController) {
//            if (![topController isKindOfClass:[OTCreateMeetingViewController class]])
//                [presentedViewController presentViewController:alert animated:YES completion:nil];
//        }];
//    }
}

- (BOOL)isMixpanelDeepLinkNotification:(NSDictionary *)userInfo {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    return [pnData.notificationType isEqualToString:@APNOTIFICATION_MIXPANEL_DEEPLINK];
}

#pragma mark - private methods

- (void)handleJoinRequestNotification:(OTPushNotificationsData *)pnData
{
    [[[OTFeedItemFactory createForType:pnData.joinableType
                                 andId:pnData.joinableId] getMessaging] getFeedItemUsersWithStatus:JOIN_PENDING                                                  success:^(NSArray *items) {
        NSNumber *userId = [pnData.extra numberForKey:@"user_id"];
        
        for (OTFeedItemJoiner *item in items) {
            if ([item.uID isEqualToNumber:userId] &&
                [item.status isEqualToString:JOIN_PENDING]) {
                [[OTUnreadMessagesService sharedInstance] incrementGroupUnreadMessagesCount:pnData.joinableId stringId:nil];
                OTFeedItemJoiner *joiner = [OTFeedItemJoiner fromPushNotifiationsData:pnData.extra];

                UIAlertAction *viewProfileAction = [UIAlertAction   actionWithTitle:OTLocalizedString(@"view_profile") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OTLogger logEvent:@"UserProfileClick"];
                    [[OTDeepLinkService new] showProfileFromAnywhereForUser:joiner.uID.stringValue isFromLaunch:NO];
                }];
                
                UIAlertAction *refuseJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OTLogger logEvent:@"RejectJoinRequest"];
                    [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getJoiner] reject:joiner success:^(){
                        [self refreshMessages:pnData];
                    } failure:nil];
                }];
                
                UIAlertAction *acceptJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"acceptAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OTLogger logEvent:@"AcceptJoinRequest"];
                    [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getJoiner] accept:joiner success:^(){
                            [self refreshMessages:pnData];
                    }failure:nil];
                }];
                
                [self displayAlertWithActions:@[refuseJoinRequestAction, acceptJoinRequestAction, viewProfileAction] forPushData:pnData];
            }
        }
    } failure:nil];
}

- (void)updateAppWindow:(UIViewController *)tabBarController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
}

- (void)handleCancelJoinNotification:(OTPushNotificationsData *)pnData {
    [[OTUnreadMessagesService sharedInstance] setGroupAsRead:pnData.joinableId
                                                          stringId:nil refreshFeed:YES];

    [OTAppState switchToMainScreenAndResetAppWindow:YES];
}

- (void)handleAcceptJoinNotification:(OTPushNotificationsData *)pnData
                    applicationState:(UIApplicationState)state
{
    if (state != UIApplicationStateActive) {
        // https://jira.mytkw.com/browse/EMA-2229
        [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.joinableId
                                                   withType:pnData.joinableType groupType:pnData.groupType];
        
    }
//    else {
//        UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * _Nonnull action) {
//            [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.joinableId withType:pnData.joinableType];
//        }];
//
//        [self displayAlertWithActions:@[openAction] forPushData:pnData];
//    }
}

- (BOOL)canHandleChatNotificationInPlace:(OTPushNotificationsData *)pnData {
    UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
    if ([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
        OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
        
        if (feedItemVC.feedItem.uid.integerValue == pnData.joinableId.integerValue) {
            [feedItemVC reloadMessages];
            return YES;
        }
    }
    
    return NO;
}

- (void)handleChatNotification:(OTPushNotificationsData *)pnData
              applicationState:(UIApplicationState)state
{
    [[OTUnreadMessagesService sharedInstance] incrementGroupUnreadMessagesCount:pnData.joinableId stringId:nil];
    
    if (state != UIApplicationStateActive) {
        [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.joinableId withType:pnData.joinableType];
        
    }
//    else {
//        // https://jira.mytkw.com/browse/EMA-2229
//        UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * _Nonnull action) {
//            [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.joinableId withType:pnData.joinableType];
//        }];
//
//        [self displayAlertWithActions:@[openAction] forPushData:pnData];
//    }
}

- (void)handleInviteRequestNotification:(OTPushNotificationsData *)pnData
{
    [[OTUnreadMessagesService sharedInstance] incrementGroupUnreadMessagesCount:pnData.entourageId stringId:nil];
    OTEntourageInvitation *invitation = [OTEntourageInvitation fromPushNotifiationsData:pnData];
    
    UIAlertAction *refuseInviteRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SVProgressHUD show];
        [[OTInvitationsService new] rejectInvitation:invitation withSuccess:^() {
            [SVProgressHUD dismiss];
            
        } failure:^(NSError *error) {
            [SVProgressHUD showWithStatus:OTLocalizedString(@"ignoreJoinFailed")];
        }];
    }];
    
    UIAlertAction *acceptInviteRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"acceptAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SVProgressHUD show];
        [[OTInvitationsService new] acceptInvitation:invitation withSuccess:^() {
            [SVProgressHUD dismiss];
            [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.entourageId withType:nil];
        } failure:^(NSError *error) {
            [SVProgressHUD showWithStatus:OTLocalizedString(@"acceptJoinFailed")];
        }];
    }];
    
    [self displayAlertWithActions:@[refuseInviteRequestAction, acceptInviteRequestAction] forPushData:pnData];
}

- (void)handleInviteStatusNotification:(OTPushNotificationsData *)pnData
{
    [[OTUnreadMessagesService sharedInstance] incrementGroupUnreadMessagesCount:pnData.feedId stringId:nil];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.feedId withType:pnData.feedType];
    }];
    [self displayAlertWithActions:@[openAction] forPushData:pnData];
}

- (void)handleMixpanelDeepLinkNotification:(OTPushNotificationsData *)pnData
{
    NSString *deeplink = (NSString *)[pnData.content objectForKey:@"mp_cta"];
    if (deeplink != nil) {
        NSURL *deeplinkURL = [NSURL URLWithString:deeplink];
        if (@available(ios 10.0, *)) {
            [[OTDeepLinkService new] handleDeepLink:deeplinkURL];
        } else {
            //for ios 9 or less, display an alert
            UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[OTDeepLinkService new] handleDeepLink:deeplinkURL];
            }];
            
            [self displayAlertWithActions:@[openAction]
                                    title:@"Entourage"
                                  message:[[pnData.content objectForKey:@"aps"] objectForKey:@"alert"]
                              forPushData:pnData];
        }
    }
}

- (void)displayAlertWithActions:(NSArray<UIAlertAction*> *)actions forPushData:(OTPushNotificationsData *)pnData  {
    [self displayAlertWithActions:actions
                            title:pnData.sender
                          message:pnData.message
                      forPushData:pnData];
}

- (void)displayAlertWithActions:(NSArray<UIAlertAction*> *)actions
                          title:(NSString *)title
                        message:(NSString *)message
                    forPushData:(OTPushNotificationsData *)pnData  {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actions) {
        [alert addAction:action];
    }
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [OTAppState hideTabBar:NO];
    }];
    
    [alert addAction:defaultAction];

    [self showAlert:alert withPresentingBlock:^(UIViewController *topController,
                                                UIViewController *presentedViewController) {
        BOOL showMessage = YES;
        
        if ([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
            OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
            
            if ([feedItemVC.feedItem.uid isEqual:pnData.joinableId]) {
                showMessage = NO;
                [feedItemVC reloadMessages];
            }
        }
        else if ([topController isKindOfClass:[OTMainViewController class]]) {
            OTMainViewController *mainController = (OTMainViewController*)topController;
            [mainController reloadFeeds];
        }
        
        if (showMessage) {
            [OTAppState hideTabBar:YES];
            
            if (presentedViewController) {
                [presentedViewController presentViewController:alert animated:YES completion:nil];
            } else {
                [topController presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (void)showAlert:(UIAlertController *)alert withPresentingBlock:(void(^)(UIViewController *, UIViewController *))presentingBlock {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    id rootViewController = appDelegate.window.rootViewController;
    UIViewController *topVC = nil;
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)rootViewController;
        id firstControlller = [tabBarController viewControllers].firstObject;
        if ([firstControlller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)firstControlller;
            topVC = [navController topViewController];
        } else {
            topVC = (UIViewController*)firstControlller;
        }
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        topVC = [navController topViewController];
    }
    
    if (topVC.presentedViewController) {
        if (presentingBlock) {
            presentingBlock(topVC, topVC.presentedViewController);
        }
    } else if (topVC) {
        [OTAppState hideTabBar:YES];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - private methods

- (void) refreshMessages:(OTPushNotificationsData *)pnData {
    UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
    
    if ([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
        OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
        
        if ([feedItemVC.feedItem.uid isEqual:pnData.joinableId]) {
            [feedItemVC reloadMessages];
        }
    }
}

@end
