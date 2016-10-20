//
//  OTFeedItemsPagination.m
//  entourage
//
//  Created by Ciprian Habuc on 15/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemsPagination.h"

@implementation OTFeedItemsPagination

- (instancetype)init {
    self = [super init];
    if (self) {
        self.feedItems = [NSMutableArray new];
        self.isLoading = NO;
        self.beforeDate = [NSDate date];
    }
    return self;
}

- (void)addFeedItems:(NSArray*)feedItems {
    self.isLoading = NO;
    if (feedItems != nil && feedItems.count > 0)
        [self.feedItems addObjectsFromArray:feedItems];
}

@end
