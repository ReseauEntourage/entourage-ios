//
//  OTEntourageInvitation.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInvitation.h"
#import "OTAPIKeys.h"
#import "NSDictionary+Parsing.h"

#define kInviter @"inviter"
#define kWSKeyEntourageId @"entourage_id"
#define kWSKeyEntourageTitle @"title"

@implementation OTEntourageInvitation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self)
    {
        self.iid = [dictionary numberForKey:kWSKeyID];
        self.inviter = [[OTUser alloc] initWithDictionary:dictionary[kInviter]];
        self.status = [dictionary stringForKey:kWSKeyStatus];
        self.entourageId = [dictionary numberForKey:kWSKeyEntourageId];
        self.title = [dictionary stringForKey:kWSKeyEntourageTitle];
    }
    return self;
}

+ (NSArray *)arrayForWebservice:(NSArray *)joiners {
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *invitationDictionary in joiners)
    {
        OTEntourageInvitation *invitation = [[OTEntourageInvitation alloc] initWithDictionary:invitationDictionary];
        [result addObject:invitation];
    }
    return result;
}

+ (OTEntourageInvitation *)fromPushNotifiationsData:(OTPushNotificationsData *)data {
    OTEntourageInvitation *result = [OTEntourageInvitation new];
    result.iid = data.invitationId;
    return result;
}

@end
