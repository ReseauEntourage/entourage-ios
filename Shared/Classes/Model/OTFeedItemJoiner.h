//
//  OTFeedItemJoiner.h
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
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
@property (strong, nonatomic) NSArray<NSString *> *communityRoles;
@property (strong, nonatomic) OTFeedItem *feedItem;
@property (strong, nonatomic) OTAssociation *partner;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)arrayForWebservice:(NSArray *)joiners;
+ (OTFeedItemJoiner *)fromPushNotifiationsData:(NSDictionary *)data;

@end
