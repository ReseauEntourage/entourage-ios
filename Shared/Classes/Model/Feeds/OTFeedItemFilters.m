//
//  OTFeedItemFilters.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemFilters.h"
#import "NSUserDefaults+OT.h"

@implementation OTFeedItemFilters

- (instancetype)init {
    self = [super init];
    if(self) {
        self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    }
    return self;
}

- (NSArray *)groupHeaders {
    return [NSArray new];
}

- (NSArray *)toGroupedArray {
    return [NSArray new];
}

- (NSArray *)parentArray {
    return [NSArray new];
}

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize {
    return [NSMutableDictionary new];
}

- (void)updateValue:(OTFeedItemFilter *)filter {
}

- (NSArray *)timeframes {
    return [NSArray new];
}

@end
