//
//  OTUserTableConfigurator.m
//  entourage
//
//  Created by sergiu buceac on 2/2/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTUserTableConfigurator.h"

@implementation OTUserTableConfigurator

+ (NSArray *)getAssociationRowsForUser:(OTUser *)user {
    NSMutableArray *mRows = [NSMutableArray arrayWithObject:@(AssociationRowTypeTitle)];
    if(user.partner)
        [mRows addObject:@(AssociationRowTypePartner)];
    if(user.organization)
        [mRows addObject:@(AssociationRowTypeOrganisation)];
    return mRows;
}

+ (NSArray *)getAssociationRowsForUserEdit:(OTUser *)user {
    NSMutableArray *mRows = [NSMutableArray new];
    if(user.partner)
        [mRows addObject:@(AssociationRowTypePartner)];
    if(user.organization)
        [mRows addObject:@(AssociationRowTypeOrganisation)];
    [mRows addObject:@(AssociationRowTypePartnerSelect)];
    return mRows;
}

@end
