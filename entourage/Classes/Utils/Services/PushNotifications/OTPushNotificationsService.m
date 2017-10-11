//
//  OTPushNotificationsService.m
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPushNotificationsService.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAuthService.h"
#import "OTConsts.h"
#import "OTActiveFeedItemViewController.h"
#import "SWRevealViewController.h"
#import "OTMainViewController.h"
#import "UIStoryboard+entourage.h"
#import "OTFeedItemJoiner.h"
#import "OTFeedItemFactory.h"
#import "OTPushNotificationsData.h"
#import "OTDeepLinkService.h"
#import "OTEntourageInvitation.h"
#import "OTInvitationsService.h"
#import "SVProgressHUD.h"
#import "OTUnreadMessagesService.h"
#import "Mixpanel/Mixpanel.h"


#define APNOTIFICATION_CHAT_MESSAGE "NEW_CHAT_MESSAGE"
#define APNOTIFICATION_JOIN_REQUEST "NEW_JOIN_REQUEST"
#define APNOTIFICATION_REQUEST_ACCEPTED "JOIN_REQUEST_ACCEPTED"
#define APNOTIFICATION_INVITE_REQUEST "ENTOURAGE_INVITATION"
#define APNOTIFICATION_INVITE_STATUS "INVITATION_STATUS"
#define APNOTIFICATION_JOIN_REQUEST_CANCELED "JOIN_REQUEST_CANCELED"

@implementation OTPushNotificationsService

- (void)sendAppInfo {
    [self sendAppInfoWithSuccess:nil orFailure:nil];
}

- (void)saveToken:(NSData *)tokenData {
    NSString *token = [[tokenData description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendAppInfo];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:token];
}

- (void)clearTokenWithSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendAppInfoWithSuccess:success orFailure:failure];
}

- (void)promptUserForPushNotifications {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST])
        [self handleJoinRequestNotification:pnData];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST_CANCELED]) 
        [self handleCancelJoinNotification:pnData];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_REQUEST_ACCEPTED])
        [self handleAcceptJoinNotification:pnData];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_CHAT_MESSAGE]) {
        if([self canHandleChatNotificationInPlace:pnData])
            return;
        else
            [self handleChatNotification:pnData];
    }
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_REQUEST])
        [self handleInviteRequestNotification:pnData];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_STATUS])
        [self handleInviteStatusNotification:pnData];
}

- (void)handleLocalNotification:(NSDictionary *)userInfo {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:pnData.sender message:pnData.message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [rootVC dismissViewControllerAnimated:YES completion:nil];
        if ([rootVC isKindOfClass:[SWRevealViewController class]])
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationLocalTourConfirmation object:nil];
        else
            [UIStoryboard showSWRevealController];
    }];
    [alert addAction:defaultAction];
    [alert addAction:openAction];
    
    [self showAlert:alert withPresentingBlock:^(UIViewController *topController, UIViewController *presentedViewController) {
        if (![topController isKindOfClass:[OTCreateMeetingViewController class]])
            [presentedViewController presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)handleAppLaunchFromNotificationCenter:(NSDictionary *)userInfo {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST])
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
}

#pragma mark - private methods

- (void)handleJoinRequestNotification:(OTPushNotificationsData *)pnData
{
    [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getMessaging] getFeedItemUsersWithStatus:JOIN_PENDING success:^(NSArray *items){
        NSNumber *userId = [pnData.extra numberForKey:@"user_id"];
        for(OTFeedItemJoiner *item in items) {
            if([item.uID isEqualToNumber:userId] && [item.status isEqualToString:JOIN_PENDING]) {
                [[OTUnreadMessagesService sharedInstance] addUnreadMessage:pnData.joinableId];
                OTFeedItemJoiner *joiner = [OTFeedItemJoiner fromPushNotifiationsData:pnData.extra];
            
                UIAlertAction *viewProfileAction = [UIAlertAction   actionWithTitle:OTLocalizedString(@"view_profile") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OTLogger logEvent:@"UserProfileClick"];
                    [[OTDeepLinkService new] showProfileFromAnywhereForUser:joiner.uID];
                }];
                UIAlertAction *refuseJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OTLogger logEvent:@"RejectJoinRequest"];
                    [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getJoiner] reject:joiner success:^(){
                        [self refreshMessages:pnData];
                    }failure:nil];
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

- (void)handleCancelJoinNotification:(OTPushNotificationsData *)pnData {
    [[OTUnreadMessagesService sharedInstance] removeUnreadMessages:pnData.joinableId];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC.presentedViewController) {
        [rootVC dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)handleAcceptJoinNotification:(OTPushNotificationsData *)pnData
{
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];

    }];
    [self displayAlertWithActions:@[openAction] forPushData:pnData];
}

- (BOOL)canHandleChatNotificationInPlace:(OTPushNotificationsData *)pnData {
    UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
    if([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
        OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
        if ([feedItemVC.feedItem.uid isEqual:pnData.joinableId]) {
            [feedItemVC reloadMessages];
            return YES;
        }
    }
    return NO;
}

- (void)handleChatNotification:(OTPushNotificationsData *)pnData
{
    [[OTUnreadMessagesService sharedInstance] addUnreadMessage:pnData.joinableId];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
    }];
    [self displayAlertWithActions:@[openAction] forPushData:pnData];
}

- (void)handleInviteRequestNotification:(OTPushNotificationsData *)pnData
{
    [[OTUnreadMessagesService sharedInstance] addUnreadMessage:pnData.entourageId];
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
            [[OTDeepLinkService new] navigateTo:pnData.entourageId withType:nil];
        } failure:^(NSError *error) {
            [SVProgressHUD showWithStatus:OTLocalizedString(@"acceptJoinFailed")];
        }];
    }];
    [self displayAlertWithActions:@[refuseInviteRequestAction, acceptInviteRequestAction] forPushData:pnData];
}

- (void)handleInviteStatusNotification:(OTPushNotificationsData *)pnData
{
    [[OTUnreadMessagesService sharedInstance] addUnreadMessage:pnData.feedId];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.feedId withType:pnData.feedType];
    }];
    [self displayAlertWithActions:@[openAction] forPushData:pnData];
}

- (void)sendAppInfoWithSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure {
    [[OTAuthService new] sendAppInfoWithSuccess:^() {
        NSLog(@"Application info sent!");
        if(success)
            success();
    }
    failure:^(NSError * error) {
        NSLog(@"ApplicationsERR: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)displayAlertWithActions:(NSArray<UIAlertAction*> *)actions forPushData:(OTPushNotificationsData *)pnData  {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:pnData.sender message:pnData.message preferredStyle:UIAlertControllerStyleAlert];
    for(UIAlertAction *action in actions)
        [alert addAction:action];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:defaultAction];
    
    [self showAlert:alert withPresentingBlock:^(UIViewController *topController, UIViewController *presentedViewController) {
        BOOL showMessage = YES;
        if ([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
            OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
            if ([feedItemVC.feedItem.uid isEqual:pnData.joinableId]) {
                showMessage = NO;
                [feedItemVC reloadMessages];
            }
        }
        if ([topController isKindOfClass:[OTMainViewController class]]) {
            OTMainViewController *mainController = (OTMainViewController*)topController;
            [mainController reloadFeeds];
        }
        if(showMessage)
            [presentedViewController presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)showAlert:(UIAlertController *)alert withPresentingBlock:(void(^)(UIViewController *, UIViewController *))presentingBlock {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC.presentedViewController) {
        UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
        if(presentingBlock)
            presentingBlock(topController, rootVC.presentedViewController);
    } else
        [rootVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private methods

- (void) refreshMessages:(OTPushNotificationsData *)pnData {
    UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
    if ([topController isKindOfClass:[OTActiveFeedItemViewController class]]) {
        OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topController;
        if ([feedItemVC.feedItem.uid isEqual:pnData.joinableId])
            [feedItemVC reloadMessages];
    }
}

@end
