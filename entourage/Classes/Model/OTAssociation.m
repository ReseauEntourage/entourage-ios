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
NSString *const kKeyDefault = @"default";

@implementation OTAssociation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.aid = [dictionary numberForKey:kKeyId];
            self.name = [dictionary stringForKey:kKeyAssociationName];
            self.smallLogoUrl = [dictionary stringForKey:kKeyAssociationSmallLogoUrl];
            self.largeLogoUrl = [dictionary stringForKey:kKeyAssociationLargeLogoUrl];
            self.isDefault = [dictionary boolForKey:kKeyDefault];
        }
    }
    return self;
}

@end
