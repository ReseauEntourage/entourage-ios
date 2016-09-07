//
//  OTPushNotificationsData.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTPushNotificationsData : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSString *notificationType;
@property (nonatomic, strong) NSNumber *joinableId;
@property (nonatomic, strong) NSString *joinableType;
@property (nonatomic, strong) NSNumber *entourageId;
@property (nonatomic, strong) NSNumber *invitationId;
@property (nonatomic, strong) NSNumber *inviteeId;
@property (nonatomic, strong) NSNumber *inviterId;
@property (nonatomic, strong) NSNumber *invitableId;
@property (nonatomic, strong) NSString *invitableType;
@property (nonatomic, strong) NSNumber *invitationAccepted;

@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, strong) NSDictionary *extra;

+ (OTPushNotificationsData  *)createFrom:(NSDictionary *)userInfo;

@end
