//
//  OTFeedItem.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItem.h"
#import "OTFeedItemAuthor.h"

@implementation OTFeedItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.creationDate = [NSDate date];
        self.updatedDate = [NSDate date];
        self.unreadMessageCount = @(0);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uuid = [dictionary stringForKey:kWSKeyUUID];
        self.uid = [dictionary numberForKey:kWSKeyID];
        self.group_type = [dictionary stringForKey:kWSKeyGroupType];
        
        //self.unreadMessageCount = @(0);
        NSDictionary *authorDictionary = [dictionary objectForKey:kWSKeyAuthor];
        if ([authorDictionary class] != [NSNull class])
          self.author = [[OTFeedItemAuthor alloc] initWithDictionary:authorDictionary];
        self.status = [dictionary stringForKey:kWSKeyStatus];
        self.joinStatus = [dictionary stringForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary stringForKey:kWSKeyType];
        self.updatedDate = [dictionary dateForKey:kWSUpdatedDate];
        self.shareUrl = [dictionary stringForKey:kWSKeyShareUrl];
        NSDictionary *lastMessageDictionary = [dictionary objectForKey:kWSKeyLastMessage];
        if ([lastMessageDictionary class] != [NSNull class]) {
            self.lastMessage = [[OTMyFeedMessage alloc] initWithDictionary:lastMessageDictionary];
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        OTFeedItem *otherItem = (OTFeedItem*)object;
        if (otherItem.uuid != nil) {
            return [self.uuid isEqualToString:otherItem.uuid] && [self.type isEqualToString:otherItem.type];
        }
    }
    return false;
}

- (BOOL)isPrivateCircle {
    return [self.group_type isEqualToString:GROUP_TYPE_PRIVATE_CIRCLE];
}

- (BOOL)isNeighborhood {
    return [self.group_type isEqualToString:GROUP_TYPE_NEIGHBORHOOD];
}

- (BOOL)isConversation {
    return [self.group_type isEqualToString:GROUP_TYPE_CONVERSATION];
}

- (BOOL)isOuting {
    return [self.group_type isEqualToString:GROUP_TYPE_OUTING];
}

@end
