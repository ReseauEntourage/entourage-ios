//
//  OTFeedItemAuthor.h
//  entourage
//
//  Created by Ciprian Habuc on 17/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAssociation.h"

@interface OTFeedItemAuthor : NSObject

@property (strong, nonatomic) NSNumber *uID;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *displayName,*partner_role_title;
@property (strong, nonatomic) OTAssociation *partner;
@property(nonatomic) BOOL hasToShowRoleAndPartner;
@property(nonatomic) BOOL isPartnerWithCurrentUser;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
