//
//  OTFeedItemJoiner.m
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemJoiner.h"
#import "NSDictionary+Parsing.h"

#define kWSKeyID @"id"
#define kWSKeyDisplayName @"display_name"
#define kWSKeyRequestedAt @"requested_at"
#define kWSKeyStatus @"status"
#define kWSKeyMessage @"message"
#define kWSKeyAvatarUrl @"avatar_url"

@implementation OTFeedItemJoiner

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.tag = TimelinePointTagJoiner;
        self.uID = [dictionary valueForKey:kWSKeyID];
        self.displayName = [dictionary valueForKey:kWSKeyDisplayName];
        if([self.displayName isKindOfClass:[NSNull class]])
            self.displayName = @"";
        self.status = [dictionary objectForKey:kWSKeyStatus];
        self.message = [dictionary objectForKey:kWSKeyMessage];
        self.avatarUrl = [dictionary objectForKey:kWSKeyAvatarUrl];
        //Java format
        self.date = [dictionary dateForKey:kWSKeyRequestedAt format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (self.date == nil)
        {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            self.date = [dictionary dateForKey:kWSKeyRequestedAt format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
    }
    return self;
}

+ (NSArray *)arrayForWebservice:(NSArray *)joiners {
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *joinerDictionary in joiners)
    {
        OTFeedItemJoiner *joiner = [[OTFeedItemJoiner alloc] initWithDictionary:joinerDictionary];
        [result addObject:joiner];
    }
    return result;
}

+ (OTFeedItemJoiner *)fromPushNotifiationsData:(NSDictionary *)data {
    OTFeedItemJoiner *joiner = [OTFeedItemJoiner new];
    joiner.uID = [data numberForKey:@"user_id"];
    return joiner;
}

@end
