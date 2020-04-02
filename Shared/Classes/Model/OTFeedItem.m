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
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithGroupType:(NSString*)groupType
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        self.groupType = groupType;
    }
    return self;
}

- (void)setupDefaults {
    self.creationDate = [NSDate date];
    self.updatedDate = [NSDate date];
    self.unreadMessageCount = @(0);
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
    copy->_joinStatus = [_joinStatus copyWithZone:zone];
    copy->_status = [_status copyWithZone:zone];
    copy->_type = [_type copyWithZone:zone];
    copy->_noPeople = [_noPeople copyWithZone:zone];
    copy->_lastMessage = _lastMessage;
    copy->_unreadMessageCount = _unreadMessageCount;
    copy->_shareUrl = [_shareUrl copyWithZone:zone];
    copy->_groupType = [_groupType copyWithZone:zone];
    copy->_identifierTag = [_identifierTag copyWithZone:zone];
    copy->_outcomeStatus = [_outcomeStatus copyWithZone:zone];
    
    copy->_startsAt = [_startsAt copyWithZone:zone];
    copy->_displayAddress = [_displayAddress copyWithZone:zone];
    copy->_streetAddress = [_streetAddress copyWithZone:zone];
    copy->_placeName = [_placeName copyWithZone:zone];
    copy->_googlePlaceId = [_googlePlaceId copyWithZone:zone];
    copy->_endsAt = [_endsAt copyWithZone:zone];
    
    return copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self && dictionary) {
        self.uuid = [dictionary stringForKey:kWSKeyUUID];
        self.uid = [dictionary numberForKey:kWSKeyID];
        self.groupType = [dictionary stringForKey:kWSKeyGroupType];
        self.status = [dictionary stringForKey:kWSKeyStatus];
        self.joinStatus = [dictionary stringForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary stringForKey:kWSKeyType];
        self.updatedDate = [dictionary dateForKey:kWSUpdatedDate];
        self.shareUrl = [dictionary stringForKey:kWSKeyShareUrl];
        NSDictionary *outcomeDictionary = [dictionary objectForKey:kWSKeyOutcome];
        if (outcomeDictionary) {
            self.outcomeStatus = [outcomeDictionary objectForKey:@"success"];
        }
        
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
            self.startsAt = [metadataDictionary dateForKey:kWSKeyStartsAt];
            self.endsAt = [metadataDictionary dateForKey:kWSKeyEndsAt];
            self.displayAddress = [metadataDictionary stringForKey:kWSKeyDisplayAddress];
            self.placeName = [metadataDictionary stringForKey:kWSKeyPlaceName];
            self.googlePlaceId = [metadataDictionary stringForKey:kWSKeyGooglePlaceId];
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
    return [self.groupType isEqualToString:GROUP_TYPE_PRIVATE_CIRCLE];
}

- (BOOL)isNeighborhood {
    return [self.groupType isEqualToString:GROUP_TYPE_NEIGHBORHOOD];
}

- (BOOL)isConversation {
    return [self.groupType isEqualToString:GROUP_TYPE_CONVERSATION];
}

- (BOOL)isOuting {
    return [self.groupType isEqualToString:GROUP_TYPE_OUTING];
}

- (BOOL)isAction {
    return [self.groupType isEqualToString:GROUP_TYPE_ACTION];
}

@end
