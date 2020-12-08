//
//  OTMyFeedMessage.m
//  entourage
//
//  Created by sergiu buceac on 9/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyFeedMessage.h"
#import "NSDictionary+Parsing.h"
#import "OTApiKeys.h"

#define kWSText @"text"

@implementation OTMyFeedMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.text = [dictionary stringForKey:kWSText];
        id author = [dictionary objectForKey:kWSKeyAuthor];
        if(author && ![author isKindOfClass:[NSNull class]] && [author isKindOfClass:[NSDictionary class]]) {
            NSDictionary *authorDict = author;
            self.firstName = [authorDict stringForKey:kWSKeyFirstname];
            self.lastName = [authorDict stringForKey:kWSKeyLastname];
            self.displayName = [authorDict stringForKey:kWSKeyDisplayName];
            self.authorId = [authorDict numberForKey:@"id"];
        }
    }
    return self;
}

@end
