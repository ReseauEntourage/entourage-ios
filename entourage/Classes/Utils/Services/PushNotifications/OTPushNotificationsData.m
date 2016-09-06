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


@implementation OTPushNotificationsData

+ (OTPushNotificationsData *)createFrom:(NSDictionary *)userInfo {
    OTPushNotificationsData *result = [OTPushNotificationsData new];
    
    result.content = [userInfo objectForKey:kUserInfoMessage];
    result.extra = [result.content objectForKey:kUserInfoExtraMessage];
    
    result.message = [userInfo stringForKey:kUserInfoObject];
    result.sender = [userInfo stringForKey:kUserInfoSender];
    result.notificationType = [result.extra valueForKey:kAPNType];
    result.joinableId = [result.extra numberForKey:kAPNJoinableId];
    result.joinableType = [result.extra valueForKey:kAPNJoinableType];
    result.entourageId = [result.extra numberForKey:kAPNEntourageId];
    result.invitationId = [result.extra numberForKey:kAPNInvitationId];
    result.inviteeId = [result.extra numberForKey:kAPNInviteeId];
    result.inviterId = [result.extra numberForKey:kAPNInviterId];
    
    return result;
}

@end
