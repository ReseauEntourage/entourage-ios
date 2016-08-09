//
//  OTEntourageInvitation.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInvitation.h"

#define kInviter @"inviter"

@implementation OTEntourageInvitation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self)
    {
        self.inviter = [[OTUser alloc] initWithDictionary:dictionary[kInviter]];
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

@end
