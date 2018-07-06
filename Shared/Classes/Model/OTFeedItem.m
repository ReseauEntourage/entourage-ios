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

- (id)copyWithZone:(NSZone *)zone
{
    OTFeedItem *copy = [[[self class] allocWithZone: zone] init];
    copy->_uuid = [_uuid copyWithZone:zone];
    copy->_uid = [_uid copyWithZone:zone];
    copy->_fid = [_fid copyWithZone:zone];
    copy->_author = _author;
    copy->_creationDate = [_creationDate copyWithZone:zone];
    copy->_updatedDate = [_updatedDate copyWithZone:zone];
    copy->_startDate = [_startDate copyWithZone:zone];
    copy->_joinStatus = [_joinStatus copyWithZone:zone];
    copy->_status = [_status copyWithZone:zone];
    copy->_type = [_type copyWithZone:zone];
    copy->_noPeople = [_noPeople copyWithZone:zone];
    copy->_lastMessage = _lastMessage;
    copy->_unreadMessageCount = _unreadMessageCount;
    copy->_shareUrl = [_shareUrl copyWithZone:zone];
    copy->_group_type = [_group_type copyWithZone:zone];
    copy->_identifierTag = [_identifierTag copyWithZone:zone];
    
    return copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uuid = [dictionary stringForKey:kWSKeyUUID];
        self.uid = [dictionary numberForKey:kWSKeyID];
        self.group_type = [dictionary stringForKey:kWSKeyGroupType];
        self.status = [dictionary stringForKey:kWSKeyStatus];
        self.joinStatus = [dictionary stringForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary stringForKey:kWSKeyType];
        self.updatedDate = [dictionary dateForKey:kWSUpdatedDate];
        self.shareUrl = [dictionary stringForKey:kWSKeyShareUrl];
        
        NSDictionary *authorDictionary = [dictionary objectForKey:kWSKeyAuthor];
        if ([authorDictionary class] != [NSNull class]) {
            self.author = [[OTFeedItemAuthor alloc] initWithDictionary:authorDictionary];
        }
        
        NSDictionary *lastMessageDictionary = [dictionary objectForKey:kWSKeyLastMessage];
        if ([lastMessageDictionary class] != [NSNull class]) {
            self.lastMessage = [[OTMyFeedMessage alloc] initWithDictionary:lastMessageDictionary];
        }
        
        NSDictionary *metadataDictionary = [dictionary objectForKey:kWSKeyMetadata];
        if ([metadataDictionary class] != [NSNull class] && metadataDictionary) {
            self.startDate = [metadataDictionary dateForKey:kWSKeyStartsAt];
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
