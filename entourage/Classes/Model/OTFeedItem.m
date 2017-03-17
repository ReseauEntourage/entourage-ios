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
        self.uid = [dictionary numberForKey:kWSKeyID];
        self.unreadMessageCount = @(0);
        NSDictionary *authorDictionary = [dictionary objectForKey:kWSKeyAuthor];
        self.author = [[OTFeedItemAuthor alloc] initWithDictionary:authorDictionary];
        self.status = [dictionary stringForKey:kWSKeyStatus];
        self.joinStatus = [dictionary stringForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary stringForKey:kWSKeyType];
        self.updatedDate = [dictionary dateForKey:kWSUpdatedDate];
        NSDictionary *lastMessageDictionary = [dictionary objectForKey:kWSKeyLastMessage];
        if([lastMessageDictionary class] != [NSNull class])
            self.lastMessage = [[OTMyFeedMessage alloc] initWithDictionary:lastMessageDictionary];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        OTFeedItem *otherItem = (OTFeedItem*)object;
        if (otherItem.uid != nil) {
            return [self.uid isEqualToValue:otherItem.uid] && [self.type isEqualToString:otherItem.type];
        }
    }
    return false;
}

@end
