//
//  OTUserMembership.m
//  entourage
//
//  Created by Smart Care on 25/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTUserMembership.h"
#import "NSDictionary+Parsing.h"

NSString *const kUserMembershipType = @"type";
NSString *const kUserMembershipList = @"list";

NSString *const kUserMembershipListItemId = @"id";
NSString *const kUserMembershipListItemTitle = @"title";

@interface OTUserMembership ()
@property (nonatomic, readwrite) NSMutableArray <OTUserMembershipListItem*> *list;
@end

@implementation OTUserMembershipListItem
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (dictionary == nil || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    self = [super init];
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.id = [dictionary numberForKey:kUserMembershipListItemId];
            self.title = [dictionary objectForKey:kUserMembershipListItemTitle];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.id forKey:kUserMembershipListItemId];
    [encoder encodeObject:self.title forKey:kUserMembershipListItemTitle];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]))
    {
        self.id = [decoder decodeObjectForKey:kUserMembershipListItemId];
        self.title = [decoder decodeObjectForKey:kUserMembershipListItemTitle];
    }
    return self;
}
@end

@implementation OTUserMembership
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (dictionary == nil || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    self = [super init];
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.type = [dictionary objectForKey:kUserMembershipType];
            self.list = [[NSMutableArray alloc] init];

            NSArray *listDictArray = [dictionary objectForKey:kUserMembershipList];
            for (NSDictionary *listDict in listDictArray) {
                OTUserMembershipListItem *item = [[OTUserMembershipListItem alloc] initWithDictionary:listDict];
                [self.list addObject:item];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.type forKey:kUserMembershipType];
    [encoder encodeObject:self.list forKey:kUserMembershipList];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]))
    {
        self.type = [decoder decodeObjectForKey:kUserMembershipType];
        self.list = [decoder decodeObjectForKey:kUserMembershipList];
    }
    return self;
}
@end
