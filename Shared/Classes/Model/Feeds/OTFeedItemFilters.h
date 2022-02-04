//
//  OTFeedItemFilters.h
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilter.h"
#import "OTUser.h"

@interface OTFeedItemFilters : NSObject

@property (nonatomic, strong) OTUser *currentUser;

- (NSArray *)toGroupedArray;
- (NSArray *)groupHeaders;
- (NSArray *)parentArray;
- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize;
- (void)updateValue:(OTFeedItemFilter *)filter;
- (NSArray *)timeframes;

@end
