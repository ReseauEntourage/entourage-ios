//
//  OTUnreadMessageCount.m
//  entourage
//
//  Created by veronica.gliga on 15/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTUnreadMessageCount.h"

NSString *const kKeyFeed = @"feedId";
NSString *const kKeyUnreadMessages = @"unreadMessages";

@implementation OTUnreadMessageCount

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.feedId forKey:kKeyFeed];
    [encoder encodeObject:self.unreadMessagesCount forKey:kKeyUnreadMessages];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.feedId = [decoder decodeObjectForKey:kKeyFeed];
        self.unreadMessagesCount = [decoder decodeObjectForKey:kKeyUnreadMessages];
    }
    return self;
}


@end
