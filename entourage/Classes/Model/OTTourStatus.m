//
//  OTTourStatus.m
//  entourage
//
//  Created by Ciprian Habuc on 11/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourStatus.h"

@implementation OTTourStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tag = TimelinePointTagStatus;
    }
    return self;
}

@end
