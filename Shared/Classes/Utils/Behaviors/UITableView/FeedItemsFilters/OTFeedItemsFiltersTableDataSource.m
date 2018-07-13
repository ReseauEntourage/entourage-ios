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
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"

@interface OTFeedItemsFiltersTableDataSource () <UITableViewDelegate>

@end

@implementation OTFeedItemsFiltersTableDataSource

- (void)initializeWith:(OTFeedItemFilters *)filter {
    [super initialize];
    
    self.currentFilter = filter;
    self.dataSource.tableView.delegate = self;
    
    self.groupHeaders = [filter groupHeaders];
    self.groupedSource = [filter toGroupedArray];
    self.parentArray = [filter parentArray];
}

- (OTFeedItemFilters *)readCurrentFilter {
    for (NSArray *values in self.groupedSource) {
        for (OTFeedItemFilter *item in values) {
            [self.currentFilter updateValue:item];
        }
    }
    
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
    CGFloat size = 44;
    
    [self readCurrentFilter];
    
    OTFeedItemFilter *contribution;
    OTFeedItemFilter *demande;
    NSArray<OTFeedItemFilter *> *parents = [self.currentFilter parentArray];
    if (parents.count > 0) {
        if (IS_PRO_USER) {
            contribution = parents[2];
            demande = parents[3];
        }
        else {
            contribution = parents[1];
            demande = parents[2];
        }
        switch (item.key) {
            case FeedItemFilterKeyDemandeSocial:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyDemandeHelp:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyDemandeResource:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyDemandeInfo:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyDemandeSkill:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyDemandeOther:
                if (!demande.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionSocial:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionHelp:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionInfo:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionResource:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionSkill:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyContributionOther:
                if (!contribution.active)
                    size = 0;
                break;
            case FeedItemFilterKeyMedical:
                if (!parents[0].active)
                    size = 0;
                break;
            case FeedItemFilterKeySocial:
                if (!parents[0].active)
                    size = 0;
                break;
            case FeedItemFilterKeyDistributive:
                if (!parents[0].active)
                    size = 0;
                break;
            case FeedItemFilterKeyEventsPast:
                if (!parents[1].active)
                    size = 0;
                break;
            case FeedItemFilterKeyTimeframe:
                return 90;
                break;
            default:
                return 44;
                break;
        }//switch(item.key)
    }//if(parents.count > 0)
    else {
        if (item.key == FeedItemFilterKeyMyOrganisationOnly && [[UIScreen mainScreen] bounds].size.width <= 321) {
            size = 65;
        }
    }
    return item.key == FeedItemFilterKeyTimeframe ? 90 : size;
}

- (void)tableView:(UITableView *)tableView
    willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemsAtSection = (NSArray *)self.groupedSource[indexPath.section];
    if (itemsAtSection.count > 10 && indexPath.row == itemsAtSection.count / 2 - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
}

@end
