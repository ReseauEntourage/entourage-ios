//
//  OTOrganization.m
//  entourage
//
//  Created by Nicolas Telera on 18/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTOrganization.h"

#import "NSDictionary+Parsing.h"

NSString *const kKeyName = @"name";
NSString *const kKeyDesc = @"description";
NSString *const kKeyPhone = @"phone";
NSString *const kKeyAddress = @"address";
NSString *const kKeyLogoUrl = @"logo_url";

@implementation OTOrganization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self)
    {
        _name = [dictionary stringForKey:kKeyName];
        _desc = [dictionary stringForKey:kKeyDesc];
        _phone = [dictionary stringForKey:kKeyPhone];
        _address = [dictionary stringForKey:kKeyAddress];
        _logoUrl = [dictionary stringForKey:kKeyLogoUrl];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:kKeyName];
    [encoder encodeObject:self.desc forKey:kKeyDesc];
    [encoder encodeObject:self.phone forKey:kKeyPhone];
    [encoder encodeObject:self.address forKey:kKeyAddress];
    [encoder encodeObject:self.logoUrl forKey:kKeyLogoUrl];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        self.name = [decoder decodeObjectForKey:kKeyName];
        self.desc = [decoder decodeObjectForKey:kKeyDesc];
        self.phone = [decoder decodeObjectForKey:kKeyPhone];
        self.address = [decoder decodeObjectForKey:kKeyAddress];
        self.logoUrl = [decoder decodeObjectForKey:kKeyLogoUrl];
    }
    return self;
}

@end