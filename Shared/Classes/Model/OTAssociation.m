//
//  OTAssociation.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociation.h"
#import "NSDictionary+Parsing.h"

NSString *const kKeyId = @"id";
NSString *const kKeyAssociationName = @"name";
NSString *const kKeyAssociationSmallLogoUrl = @"small_logo_url";
NSString *const kKeyAssociationLargeLogoUrl = @"large_logo_url";
NSString *const kKeyAssociationDescription = @"description";
NSString *const kKeyAssociationPhone = @"phone";
NSString *const kKeyAssociationAddress = @"address";
NSString *const kKeyAssociationWebsiteUrl = @"website_url";
NSString *const kKeyAssociationEmail = @"email";
NSString *const kKeyDefault = @"default";
NSString *const kKeyUserAssociationRoleTitle = @"user_role_title";
NSString *const kKeyPostalCode = @"postal_code";
NSString *const kVolunteers_needs = @"volunteers_needs";
NSString *const kDonations_needs = @"donations_needs";

@implementation OTAssociation

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]])
        return nil;
    self = [super init];
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Parsing Association : %@",dictionary);
            self.aid = [dictionary numberForKey:kKeyId];
            self.name = [dictionary stringForKey:kKeyAssociationName];
            self.smallLogoUrl = [dictionary stringForKey:kKeyAssociationSmallLogoUrl];
            self.largeLogoUrl = [dictionary stringForKey:kKeyAssociationLargeLogoUrl];
            self.descr = [dictionary stringForKey:kKeyAssociationDescription];
            self.phone = [dictionary stringForKey:kKeyAssociationPhone];
            self.address = [dictionary stringForKey:kKeyAssociationAddress];
            self.websiteUrl = [dictionary stringForKey:kKeyAssociationWebsiteUrl];
            self.email = [dictionary stringForKey:kKeyAssociationEmail];
            self.isDefault = [dictionary boolForKey:kKeyDefault];
            self.userRoleTitle = [dictionary stringForKey:kKeyUserAssociationRoleTitle];
            self.postal_code = [dictionary stringForKey:kKeyPostalCode];
            self.donations_needs = [dictionary stringForKey:kDonations_needs];
            self.volunteers_needs = [dictionary stringForKey:kVolunteers_needs];
            
            if ([self.donations_needs isEqualToString:@"<null>"]) {
                self.donations_needs = nil;
            }
            if ([self.volunteers_needs isEqualToString:@"<null>"]) {
                self.volunteers_needs = nil;
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.aid forKey:kKeyId];
    [encoder encodeObject:self.name forKey:kKeyAssociationName];
    [encoder encodeObject:self.smallLogoUrl forKey:kKeyAssociationSmallLogoUrl];
    [encoder encodeObject:self.largeLogoUrl forKey:kKeyAssociationLargeLogoUrl];
    [encoder encodeObject:self.descr forKey:kKeyAssociationDescription];
    [encoder encodeObject:self.phone forKey:kKeyAssociationPhone];
    [encoder encodeObject:self.address forKey:kKeyAssociationAddress];
    [encoder encodeObject:self.websiteUrl forKey:kKeyAssociationWebsiteUrl];
    [encoder encodeObject:self.email forKey:kKeyAssociationEmail];
    [encoder encodeBool:self.isDefault forKey:kKeyDefault];
    [encoder encodeObject:self.userRoleTitle forKey:kKeyUserAssociationRoleTitle];
    [encoder encodeObject:self.postal_code forKey:kKeyPostalCode];
    [encoder encodeObject:self.donations_needs forKey:kDonations_needs];
    [encoder encodeObject:self.volunteers_needs forKey:kVolunteers_needs];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]))
    {
        self.aid = [decoder decodeObjectForKey:kKeyId];
        self.name = [decoder decodeObjectForKey:kKeyAssociationName];
        self.smallLogoUrl = [decoder decodeObjectForKey:kKeyAssociationSmallLogoUrl];
        self.largeLogoUrl = [decoder decodeObjectForKey:kKeyAssociationLargeLogoUrl];
        self.descr = [decoder decodeObjectForKey:kKeyAssociationDescription];
        self.phone = [decoder decodeObjectForKey:kKeyAssociationPhone];
        self.address = [decoder decodeObjectForKey:kKeyAssociationAddress];
        self.websiteUrl = [decoder decodeObjectForKey:kKeyAssociationWebsiteUrl];
        self.email = [decoder decodeObjectForKey:kKeyAssociationEmail];
        self.isDefault = [decoder decodeBoolForKey:kKeyDefault];
        self.userRoleTitle = [decoder decodeObjectForKey:kKeyUserAssociationRoleTitle];
        self.postal_code = [decoder decodeObjectForKey:kKeyPostalCode];
        self.donations_needs = [decoder decodeObjectForKey:kDonations_needs];
        self.volunteers_needs = [decoder decodeObjectForKey:kVolunteers_needs];
    }
    return self;
}

@end
