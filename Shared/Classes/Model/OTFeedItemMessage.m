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
#define kWSPartner @"partner"
#define kWSMessageType @"message_type"
#define kWSDisplayAddress @"display_address"
#define kWSTitle @"title"
#define kWSUuid @"uuid"
#define kWSMetadata @"metadata"
#define kWSMetadataType @"type"

@implementation OTFeedItemMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.tID = [dictionary numberForKey:kWSID];
        self.tag = TimelinePointTagMessage;
        self.date = [self dateFromDictionary:dictionary key:kWSKeyCreatedAt];
        self.text = [dictionary stringForKey:kWSKeyContent];
        
        NSDictionary *user = nil;
        if ((user = [dictionary objectForKey:kWSUser])) {
            self.userAvatarURL = [user stringForKey:kWSAvatarURL];
            self.uID = [user numberForKey:kWSID];
            self.userName = [user stringForKey:kWSUserName];
            self.partner = [[OTAssociation alloc] initWithDictionary:[user objectForKey:kWSPartner]];
        }
        
        self.messageType = [dictionary stringForKey:kWSMessageType];
        NSDictionary *metadata = [dictionary objectForKey:kWSMetadata];
        if (metadata) {
            self.title = [metadata stringForKey:kWSTitle];
            self.displayAddress = [metadata stringForKey:kWSDisplayAddress];
            self.itemUuid = [metadata stringForKey:kWSUuid];
            self.startsAt = [self dateFromDictionary:metadata key:kWSKeyStartsAt];
            self.itemType = [metadata stringForKey:kWSMetadataType];
        }
    }
    return self;
}

- (NSDate*)dateFromDictionary:(NSDictionary*)dictionary key:(NSString*)key {
    NSDate *date = [dictionary dateForKey:key format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
    if (date == nil) {
        // Objective-C format : "2015-11-20 09:28:52 +0000"
        date = [dictionary dateForKey:key format:@"yyyy-MM-dd HH:mm:ss Z"];
    }
    
    return date;
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

// Event Created Cell
/*
 {
 content = "a cr\U00e9\U00e9 une sortie :\nI\nle 16/08 \U00e0 14h48,\n14 Rue de Rivoli, 75004 Paris";
 "created_at" = "2018-08-02T14:51:11.258+02:00";
 id = 2978;
 "message_type" = outing;
 metadata =             {
 "display_address" = "14 Rue de Rivoli, 75004 Paris";
 operation = created;
 "starts_at" = "2018-08-16T14:48:00.677+02:00";
 title = I;
 uuid = e5Vlog5BjGoI;
 };
 user =             {
 "avatar_url" = "https://entourage-avatars-production-thumb.s3-eu-west-1.amazonaws.com/pfp/staging/300x300/user_2909.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAJT44R775SCEY47YA%2F20180803%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20180803T080953Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=b5c0e4d89c97f04e3b13be6402a8ed4fbe30d9a5e3732a955ec6a59f4f0139a8";
 "display_name" = "Bob P";
 id = 2909;
 partner = "<null>";
 };
 },
 */



@end
