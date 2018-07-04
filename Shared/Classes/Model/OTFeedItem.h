//
//  OTFeedItem.h
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAPIKeys.h"
#import "NSDictionary+Parsing.h"
#import "OTFeedItemAuthor.h"
#import "OTMyFeedMessage.h"

#define FEEDITEM_STATUS_ACTIVE @"active"
#define FEEDITEM_STATUS_CLOSED @"closed"

#define JOIN_ACCEPTED @"accepted"
#define JOIN_PENDING @"pending"
#define JOIN_NOT_REQUESTED @"not_requested"
#define JOIN_REJECTED @"rejected"
#define JOIN_CANCELLED @"cancelled"

#define TOUR_TYPE_NAME @"Tour"

@interface OTFeedItem : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSString *fid;
@property (nonatomic, strong) OTFeedItemAuthor *author;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *updatedDate;
@property (nonatomic, strong) NSString *joinStatus;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *noPeople;
@property (nonatomic, strong) OTMyFeedMessage *lastMessage;
@property (nonatomic, assign) NSNumber *unreadMessageCount;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *group_type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isPrivateCircle;
- (BOOL)isNeighborhood;
- (BOOL)isConversation;
- (BOOL)isOuting;

@end
