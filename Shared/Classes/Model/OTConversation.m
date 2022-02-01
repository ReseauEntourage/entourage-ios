//
//  OTConversation.m
//  entourage
//
//  Created by Smart Care on 14/06/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTConversation.h"

@implementation OTConversation

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
            self.uuid = [dictionary stringForKey:kWSKeyUUID];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uuid forKey:kWSKeyUUID];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]))
    {
        self.uuid = [decoder decodeObjectForKey:kWSKeyUUID];
    }
    return self;
}
@end
