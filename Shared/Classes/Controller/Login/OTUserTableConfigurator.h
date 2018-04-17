//
//  OTUserTableConfigurator.h
//  entourage
//
//  Created by sergiu buceac on 2/2/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

typedef NS_ENUM(NSInteger) {
    AssociationRowTypeTitle,
    AssociationRowTypePartner,
    AssociationRowTypeOrganisation,
    AssociationRowTypePartnerSelect
} AssociationRowType;

@interface OTUserTableConfigurator : NSObject

+ (NSArray *)getAssociationRowsForUser:(OTUser *)user;
+ (NSArray *)getAssociationRowsForUserEdit:(OTUser *)user;

@end
