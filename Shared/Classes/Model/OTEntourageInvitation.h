//
//  OTEntourageInvitation.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"
#import "OTPushNotificationsData.h"

#define INVITATION_ACCEPTED @"accepted"
#define INVITATION_PENDING @"pending"

@interface OTEntourageInvitation : NSObject

@property (nonatomic, strong) NSNumber *iid;
@property (nonatomic, strong) OTUser *inviter;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *entourageId;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)arrayForWebservice:(NSArray *)joiners;
+ (OTEntourageInvitation *)fromPushNotifiationsData:(OTPushNotificationsData *)data;

@end
