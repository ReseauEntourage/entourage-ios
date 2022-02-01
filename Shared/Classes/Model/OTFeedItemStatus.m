//
//  OTFeedItemStatus.m
//
//  Created by Ciprian Habuc on 11/03/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTFeedItemStatus.h"

@implementation OTFeedItemStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tag = TimelinePointTagStatus;
    }
    return self;
}

@end
