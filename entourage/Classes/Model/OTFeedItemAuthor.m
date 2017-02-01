//
//  OTFeedItemAuthor.m
//  entourage
//
//  Created by Ciprian Habuc on 17/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemAuthor.h"
#import "NSDictionary+Parsing.h"

#define kWSuid @"id"
#define kWDisplayName @"display_name"
#define kWSAvatar_URL @"avatar_url"
#define kWSPartner @"partner"

@implementation OTFeedItemAuthor

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.uID = [dictionary valueForKey:kWSuid];
        NSString *dnameVal = [dictionary valueForKey:kWDisplayName];
        self.displayName = [dnameVal isKindOfClass:[NSNull class]] ? @"" : dnameVal;
        self.avatarUrl = [dictionary stringForKey:kWSAvatar_URL];
        self.partner = [[OTAssociation alloc] initWithDictionary:[dictionary objectForKey:kWSPartner]];
    }
    return self;
}

@end
