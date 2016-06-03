//
//  OTFeedItem.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItem.h"
#import "OTTourAuthor.h"


@implementation OTFeedItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uid = [dictionary numberForKey:kWSKeyID];
        NSDictionary *authorDictionary = [dictionary objectForKey:kWSKeyAuthor];
        self.author = [[OTTourAuthor alloc] initWithDictionary:authorDictionary];
        self.status = [dictionary valueForKey:kWSKeyStatus];
        NSLog(@"STATUS == %@", self.status);
        self.joinStatus = [dictionary valueForKey:kWSKeyJoinStatus];
        self.noPeople = [dictionary numberForKey:kWSKeyNoPeople];
        self.type = [dictionary valueForKey:kWSKeyType];
    }
    return self;
}

- (NSString *)navigationTitle {
    return nil;
}

- (NSString *)summary {
    return nil;
}

- (NSAttributedString *)typeByNameAttributedString {
    return nil;
}

- (NSString *)newsfeedStatus {
    return self.status;
}

@end
