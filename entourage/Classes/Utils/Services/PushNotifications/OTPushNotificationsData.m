//
//  OTPushNotificationsData.m
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPushNotificationsData.h"
#import "NSDictionary+Parsing.h"

#define kUserInfoSender @"sender"
#define kUserInfoObject @"object"
#define kUserInfoMessage @"content"
#define kUserInfoExtraMessage @"extra"
#define kAPNType @"type"
#define kAPNJoinableId @"joinable_id"
#define kAPNJoinableType @"joinable_type"
#define kAPNEntourageId @"entourage_id"
#define kAPNInvitationId @"invitation_id"
#define kAPNInviteeId @"invitee_id"
#define kAPNInviterId @"inviter_id"
#define kAPNInvitableId @"invitable_id"
#define kAPNInvitableType @"invitable_type"
#define kAPNInvitationAccepted @"accepted"

@implementation OTPushNotificationsData

+ (OTPushNotificationsData *)createFrom:(NSDictionary *)userInfo {
    OTPushNotificationsData *result = [OTPushNotificationsData new];
    
    result.content = [userInfo objectForKey:kUserInfoMessage];
    result.extra = [result.content objectForKey:kUserInfoExtraMessage];
    
    result.message = [userInfo stringForKey:kUserInfoObject];
    result.sender = [userInfo stringForKey:kUserInfoSender];
    result.notificationType = [result.extra stringForKey:kAPNType];
    result.joinableId = [result.extra numberForKey:kAPNJoinableId];
    result.joinableType = [result.extra stringForKey:kAPNJoinableType];
    result.entourageId = [result.extra numberForKey:kAPNEntourageId];
    result.invitationId = [result.extra numberForKey:kAPNInvitationId];
    result.inviteeId = [result.extra numberForKey:kAPNInviteeId];
    result.inviterId = [result.extra numberForKey:kAPNInviterId];
    result.invitableId = [result.extra numberForKey:kAPNInvitableId];
    result.invitableType = [result.extra stringForKey:kAPNInvitableType];
    result.invitationAccepted = [result.extra numberForKey:kAPNInvitationAccepted];
    
    return result;
}

@end
