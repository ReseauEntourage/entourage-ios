//
//  OTFeedItemJoiner.h
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemTimelinePoint.h"
#import "OTFeedItem.h"
#import "OTAssociation.h"

@interface OTFeedItemJoiner : OTFeedItemTimelinePoint

@property (strong, nonatomic) NSNumber *uID;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *groupRole;
@property (strong, nonatomic) NSString *partner_role_title;
@property (strong, nonatomic) NSArray<NSString *> *communityRoles;
@property (strong, nonatomic) OTFeedItem *feedItem;
@property (strong, nonatomic) OTAssociation *partner;

@property(nonatomic) BOOL hasToShowRoleAndPartner;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)arrayForWebservice:(NSArray *)joiners;
+ (OTFeedItemJoiner *)fromPushNotifiationsData:(NSDictionary *)data;

@end
