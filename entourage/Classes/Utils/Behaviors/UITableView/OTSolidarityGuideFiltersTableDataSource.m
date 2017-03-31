//
//  OTSolidarityGuideFiltersTableDataSource.m
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFiltersTableDataSource.h"
#import "OTSolidarityGuideFilter.h"
#import "UIColor+entourage.h"
#import "OTDataSourceBehavior.h"

@interface OTSolidarityGuideFiltersTableDataSource () <UITableViewDelegate>

@end

@implementation OTSolidarityGuideFiltersTableDataSource

- (void)initializeWith:(OTSolidarityGuideFilter *)filter {
    [super initialize];
    
    self.currentFilter = filter;
    self.groupHeaders = [filter groupHeaders];
    self.groupedSource = [filter toGroupedArray];
    [self.dataSource updateItems:self.groupedSource];
    self.dataSource.tableView.delegate = self;
}

- (OTSolidarityGuideFilter *)readCurrentFilter {
    for(NSArray *values in self.groupedSource)
        for(OTSolidarityGuideFilter *item in values)
            [self.currentFilter updateValue:item];
    return self.currentFilter;
}

- (void)refresh {
    self.groupedSource = self.dataSource.items;
    [super refresh];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor appGreyishBrownColor];
    header.textLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.tintColor = [UIColor appPaleGreyColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemsAtSection = (NSArray *)self.groupedSource[indexPath.section];
    if(indexPath.row == itemsAtSection.count - 1)
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
}


@end
