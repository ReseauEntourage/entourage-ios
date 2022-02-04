//
//  OTUserTableConfigurator.m
//  entourage
//
//  Created by sergiu buceac on 2/2/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTUserTableConfigurator.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

@implementation OTUserTableConfigurator

+ (NSArray *)getAssociationRowsForUser:(OTUser *)user {
    NSMutableArray *mRows = [NSMutableArray arrayWithObject:@(AssociationRowTypeTitle)];
    if(user.partner)
        [mRows addObject:@(AssociationRowTypePartner)];
    if(user.organization && [user.type isEqualToString:USER_TYPE_PRO])
        [mRows addObject:@(AssociationRowTypeOrganisation)];
    return mRows;
}

+ (NSArray *)getAssociationRowsForUserEdit:(OTUser *)user {
    NSMutableArray *mRows = [NSMutableArray new];
    mRows = nil;
    if(user.partner)
        [mRows addObject:@(AssociationRowTypePartner)];
    if(user.organization && [user.type isEqualToString:USER_TYPE_PRO])
        [mRows addObject:@(AssociationRowTypeOrganisation)];
    return mRows;
}

@end
