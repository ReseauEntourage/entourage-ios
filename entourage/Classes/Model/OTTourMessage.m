//
//  OTTourMessage.m
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourMessage.h"
#import "NSDictionary+Parsing.h"


#define kWSKeyContent @"content"
#define kWSKeyCreatedAt @"created_at"
#define kWSUser @"user"
#define kWSAvatarURL @"avatar_url"


@implementation OTTourMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.date = [dictionary dateForKey:kWSKeyCreatedAt format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (self.date == nil)
        {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            self.date = [dictionary dateForKey:kWSKeyCreatedAt format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
        self.text = [dictionary valueForKey:kWSKeyContent];
        NSDictionary *user;
        if ((user = [dictionary objectForKey:kWSUser])) {
            self.userAvatarURL = [user valueForKey:kWSAvatarURL];
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
