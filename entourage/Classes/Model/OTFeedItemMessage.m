//
//  OTFeedItemMessage.m
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemMessage.h"
#import "NSDictionary+Parsing.h"


#define kWSKeyContent @"content"
#define kWSKeyCreatedAt @"created_at"
#define kWSUser @"user"
#define kWSUserName @"display_name"
#define kWSAvatarURL @"avatar_url"
#define kWSID @"id"

@implementation OTFeedItemMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.tID = [dictionary numberForKey:kWSID];
        self.tag = TimelinePointTagMessage;
        self.date = [dictionary dateForKey:kWSKeyCreatedAt format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (self.date == nil)
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            self.date = [dictionary dateForKey:kWSKeyCreatedAt format:@"yyyy-MM-dd HH:mm:ss Z"];
        self.text = [dictionary stringForKey:kWSKeyContent];
        NSDictionary *user;
        if ((user = [dictionary objectForKey:kWSUser])) {
            self.userAvatarURL = [user stringForKey:kWSAvatarURL];
            self.uID = [user numberForKey:kWSID];
            self.userName = [user stringForKey:kWSUserName];
        }
    }
    return self;
}

/*
 "id": 123,
 "content": "Content text",
 "user": {
    "id": 456,
    "avatar_url": "https://foo.bar"
 }
 "created_at": "2015-07-07T10:31:43.000+02:00"
 */



@end
