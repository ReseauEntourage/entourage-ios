//
//  OTFeedItemsFiltersTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemsFiltersTableDataSource.h"
#import "OTConsts.h"
#import "OTFeedItemTimeframeFilter.h"
#import "OTFeedItemFilter.h"
#import "OTDataSourceBehavior.h"
#import "UIColor+entourage.h"

@interface OTFeedItemsFiltersTableDataSource () <UITableViewDelegate>

@end

@implementation OTFeedItemsFiltersTableDataSource

- (void)initializeWith:(OTFeedItemFilters *)filter {
    [super initialize];
    
    self.currentFilter = filter;
    self.dataSource.tableView.delegate = self;
    self.groupHeaders = [filter groupHeaders];
    self.groupedSource = [filter toGroupedArray];
}

- (OTFeedItemFilters *)readCurrentFilter {
    for(NSArray *values in self.groupedSource)
        for(OTFeedItemFilter *item in values)
            [self.currentFilter updateValue:item];
    return self.currentFilter;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor appGreyishBrownColor];
    header.textLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.tintColor = [UIColor appPaleGreyColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTFeedItemFilter *item = (OTFeedItemFilter *)[self getItemAtIndexPath:indexPath];
    return item.key == FeedItemFilterKeyTimeframe ? 90 : 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemsAtSection = (NSArray *)self.groupedSource[indexPath.section];
    if(indexPath.row == itemsAtSection.count - 1)
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
}


@end
