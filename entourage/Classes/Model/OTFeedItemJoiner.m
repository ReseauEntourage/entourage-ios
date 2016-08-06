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

@implementation OTFeedItemJoiner

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.tag = TimelinePointTagJoiner;
        _uID = [dictionary valueForKey:kWSKeyID];
        _displayName = [dictionary valueForKey:kWSKeyDisplayName];
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

@end
