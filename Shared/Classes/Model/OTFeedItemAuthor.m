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
#define kWSPartnerRoleTitle @"partner_role_title"
#define kWSpartner_with_current_user @"partner_with_current_user"

@implementation OTFeedItemAuthor

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.uID = [dictionary valueForKey:kWSuid];
        NSString *dnameVal = [dictionary valueForKey:kWDisplayName];
        self.displayName = [dnameVal isKindOfClass:[NSNull class]] ? @"" : dnameVal;
        self.avatarUrl = [dictionary stringForKey:kWSAvatar_URL];
        self.partner = [[OTAssociation alloc] initWithDictionary:[dictionary objectForKey:kWSPartner]];
        self.partner_role_title = [dictionary stringForKey:kWSPartnerRoleTitle];
        self.isPartnerWithCurrentUser = [dictionary boolForKey:kWSpartner_with_current_user];
        
        if (self.partner != nil || (self.partner_role_title != nil  && self.partner_role_title.length > 0)) {
            self.hasToShowRoleAndPartner = YES;
        }
        else {
            self.hasToShowRoleAndPartner = NO;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.uID forKey:kWSuid];
    [encoder encodeObject:self.displayName forKey:kWDisplayName];
    [encoder encodeObject:self.avatarUrl forKey:kWSAvatar_URL];
    [encoder encodeObject:self.partner forKey:kWSPartner];
    [encoder encodeObject:self.partner_role_title forKey:kWSPartnerRoleTitle];
    [encoder encodeBool:self.isPartnerWithCurrentUser forKey:kWSpartner_with_current_user];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        self.uID = [decoder decodeObjectForKey:kWSuid];
        self.displayName = [decoder decodeObjectForKey:kWDisplayName];
        self.avatarUrl = [decoder decodeObjectForKey:kWSAvatar_URL];
        self.partner = [decoder decodeObjectForKey:kWSPartner];
        self.partner_role_title = [decoder decodeObjectForKey:kWSPartnerRoleTitle];
        self.isPartnerWithCurrentUser = [decoder decodeBoolForKey:kWSpartner_with_current_user];
    }
    return self;
}

@end
