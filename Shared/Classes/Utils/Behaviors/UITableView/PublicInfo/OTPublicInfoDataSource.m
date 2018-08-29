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
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // Summary row
    feedItem.identifierTag = @"summary";
    [items addObject:feedItem.copy];
    
    if ([feedItem isOuting]) {
        // Event creator row
        feedItem.identifierTag = @"eventAuthorInfo";
        [items addObject:feedItem.copy];
        
        // Event info row
        feedItem.identifierTag = @"eventInfo";
        [items addObject:feedItem.copy];
    }
    
    // Map row
    feedItem.identifierTag = @"feedLocation";
    [items addObject:feedItem.copy];
    
    // Description row
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    if ([description length] > 0) {
        feedItem.identifierTag = @"feedDescription";
        [items addObject:feedItem.copy];
    }
    
    [self updateItems:items];
}

@end
