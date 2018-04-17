//
//  OTSolidarityGuideFilteredDataSource.m
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilteredDataSource.h"
#import "OTSolidarityGuideFilterItem.h"
#import "OTTableDataSourceBehavior.h"

@interface OTSolidarityGuideFilteredDataSource ()

@property (nonatomic, strong) NSMutableArray* items;

@end

@implementation OTSolidarityGuideFilteredDataSource

@synthesize items;

- (void) filterItemsByString:(NSString *)searchString {
    if([searchString length] == 0) {
        self.items = [NSMutableArray arrayWithObject:[self.allItems objectAtIndex:0]];
    }
    else {
        NSMutableArray *filtered = [NSMutableArray new];
        for(NSArray *header in self.allItems) {
            for(OTSolidarityGuideFilterItem* filter in header) {
                NSRange rangeValue = [filter.title rangeOfString:searchString options:NSCaseInsensitiveSearch];
                if(rangeValue.length > 0)
                   [filtered addObject:filter];
            }
        }
        self.items = [NSMutableArray arrayWithObject:filtered];
    }
    [self.tableDataSource refresh];
}

@end
