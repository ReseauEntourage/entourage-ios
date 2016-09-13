//
//  OTFeedItemsPagination.h
//  entourage
//
//  Created by Ciprian Habuc on 15/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FEEDITEMS_PER_PAGE 10

@interface OTFeedItemsPagination : NSObject

@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *feedItems;
@property (nonatomic, strong) NSDate *beforeDate;

- (void)addFeedItems:(NSArray*)feedItems;

@end
