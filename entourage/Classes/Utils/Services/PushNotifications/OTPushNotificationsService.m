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
#import "OTDeepLinkService.h"
#import "OTPushNotificationsData.h"
#import "OTDeepLinkService.h"
#import "OTEntourageInvitation.h"
#import "OTInvitationsService.h"
#import "SVProgressHUD.h"

#define APNOTIFICATION_CHAT_MESSAGE "NEW_CHAT_MESSAGE"
#define APNOTIFICATION_JOIN_REQUEST "NEW_JOIN_REQUEST"
#define APNOTIFICATION_REQUEST_ACCEPTED "JOIN_REQUEST_ACCEPTED"
#define APNOTIFICATION_INVITE_REQUEST "ENTOURAGE_INVITATION"
#define APNOTIFICATION_INVITE_STATUS "INVITATION_STATUS"

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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:pnData.sender message:pnData.message preferredStyle:UIAlertControllerStyleAlert];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST])
        [self handleJoinRequestNotification:pnData showingAlert:alert];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_REQUEST_ACCEPTED])
        [self handleAcceptJoinNotification:pnData showingAlert:alert];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_CHAT_MESSAGE])
        [self handleChatNotification:pnData showingAlert:alert];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_REQUEST])
        [self handleInviteRequestNotification:pnData showingAlert:alert];
    else if ([pnData.notificationType isEqualToString:@APNOTIFICATION_INVITE_STATUS])
        [self handleInviteStatusNotification:pnData showingAlert:alert];
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
            [mainController getData];
        }
        if(showMessage)
            [presentedViewController presentViewController:alert animated:YES completion:nil];
    }];
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

#pragma mark - private methods

- (void)handleJoinRequestNotification:(OTPushNotificationsData *)pnData showingAlert:(UIAlertController*)alert
{
    OTFeedItemJoiner *joiner = [OTFeedItemJoiner fromPushNotifiationsData:pnData.extra];
    UIAlertAction *refuseJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getJoiner] reject:joiner success:nil failure:nil];
    }];
    UIAlertAction *acceptJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"acceptAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[[OTFeedItemFactory createForType:pnData.joinableType andId:pnData.joinableId] getJoiner] accept:joiner success:nil failure:nil];
    }];
    [alert addAction:refuseJoinRequestAction];
    [alert addAction:acceptJoinRequestAction];
}

- (void)handleAcceptJoinNotification:(OTPushNotificationsData *)pnData showingAlert:(UIAlertController*)alert
{
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
    }];
    [alert addAction:openAction];
}

- (void)handleChatNotification:(OTPushNotificationsData *)pnData showingAlert:(UIAlertController*)alert
{
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
    }];
    [alert addAction:openAction];
}

- (void)handleInviteRequestNotification:(OTPushNotificationsData *)pnData showingAlert:(UIAlertController*)alert
{
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
    [alert addAction:refuseInviteRequestAction];
    [alert addAction:acceptInviteRequestAction];
}

- (void)handleInviteStatusNotification:(OTPushNotificationsData *)pnData showingAlert:(UIAlertController*)alert
{
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:pnData.feedId withType:pnData.feedType];
    }];
    [alert addAction:openAction];
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

@end
