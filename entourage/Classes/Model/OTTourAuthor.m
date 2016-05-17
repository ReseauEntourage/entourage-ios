//
//  OTTourAuthor.m
//  entourage
//
//  Created by Ciprian Habuc on 17/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourAuthor.h"

#define kWSuid @"id"
#define kWDisplayName @"display_name"
#define kWSAvatar_URL @"avatar_url"



@implementation OTTourAuthor

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.uID = [dictionary valueForKey:kWSuid];
        self.displayName = [dictionary valueForKey:kWDisplayName];
        self.avatarUrl = [dictionary valueForKey:kWSAvatar_URL];
    }
    return self;
}

@end
