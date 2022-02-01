//
//  OTAnnouncement.m
//  entourage
//
//  Created by veronica.gliga on 02/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTAnnouncement.h"

@implementation OTAnnouncement

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.title = [dictionary stringForKey:kWSKeyTitle];
        self.body = [dictionary stringForKey:kWSKeyBody];
        self.action = [dictionary stringForKey:kWSKeyAction];
        self.url = [dictionary stringForKey:kWSKeyUrl];
        self.icon_url = [dictionary stringForKey:kWSKeyIconUrl];
        self.image_url = [dictionary stringForKey:kWSKeyImageUrl];
    }
    return self;
}

@end
