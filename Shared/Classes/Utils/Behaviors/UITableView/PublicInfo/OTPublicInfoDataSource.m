//
//  OTPublicInfoDataSource.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicInfoDataSource.h"
#import "OTFeedItemFactory.h"

@implementation OTPublicInfoDataSource

- (void)loadDataFor:(OTFeedItem *)feedItem {
    NSMutableArray *items = [NSMutableArray arrayWithArray:@[feedItem, feedItem]];
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    
    if ([description length] > 0) {
        feedItem.identifierTag = @"feedDescription";
        [items addObject:feedItem.copy];
    }
    
    [self updateItems:items];
}

@end
