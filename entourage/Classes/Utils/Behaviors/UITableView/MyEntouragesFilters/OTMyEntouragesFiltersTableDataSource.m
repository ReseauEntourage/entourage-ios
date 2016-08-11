//
//  OTMyEntouragesFiltersTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFiltersTableDataSource.h"
#import "OTConsts.h"
#import "OTMyEntourageTimeframeFilter.h"
#import "OTDataSourceBehavior.h"
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@interface OTMyEntouragesFiltersTableDataSource () <UITableViewDelegate>

@end

@implementation OTMyEntouragesFiltersTableDataSource

- (void)initializeWith:(OTMyEntouragesFilter *)filter {
    [super initialize];
    
    self.dataSource.tableView.delegate = self;
    if([[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO])
        self.groupedSource = @{
            OTLocalizedString(@"myEntouragesTitle") : @[
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyActive active:filter.isActive],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyInvitation active:filter.isInvited],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyOrganiser active:filter.isOrganiser],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyClosed active:filter.isClosed]
            ],
            OTLocalizedString(@"filter_entourages_title") : @[
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyDemand active:filter.showDemand],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyContribution active:filter.showContribution],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyTour active:filter.showTours]
            ]
        };
    else
        self.groupedSource = @{
            OTLocalizedString(@"filter_entourages_title") : @[
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyDemand active:filter.showDemand],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyContribution active:filter.showContribution],
                [OTMyEntourageFilter createFor:MyEntourageFilterKeyOnlyMyEntourages active:filter.showOnlyMyEntourages]
            ],
            OTLocalizedString(@"filter_timeframe_title") : @[
                [OTMyEntourageTimeframeFilter createFor:MyEntourageFilterKeyTimeframe timeframeInHours:filter.timeframeInHours]
            ]
        };
    self.quickJumpList = [self.groupedSource allKeys];
}

- (OTMyEntouragesFilter *)readCurrentFilter {
    OTMyEntouragesFilter *result = [OTMyEntouragesFilter new];
    for(NSArray *values in self.groupedSource.allValues)
        for(OTMyEntourageFilter *item in values)
            [item change:result];
    return result;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor appGreyishBrownColor];
    header.textLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    header.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTMyEntourageFilter *item = (OTMyEntourageFilter *)[self getItemAtIndexPath:indexPath];
    return item.key == MyEntourageFilterKeyTimeframe ? 90 : 44;
}

@end
