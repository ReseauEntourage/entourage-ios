//
//  OTFeedItem.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItem.h"
#import "OTTourAuthor.h"


@implementation OTFeedItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.creationDate = [NSDate date];
        self.updatedDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uid = [dictionary numberForKey:kWSKeyID];
        NSDictionary *authorDictionary = [dictionary objectForKey:kWSKeyAuthor];
        self.author = [[OTTourAuthor alloc] initWithDictionary:authorDictionary];
        self.status = [dictionary valueForKey:kWSKeyStatus];
        self.joinStatus = [dictionary valueForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary valueForKey:kWSKeyType];
        self.updatedDate = [dictionary dateForKey:kWSUpdatedDate];
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
