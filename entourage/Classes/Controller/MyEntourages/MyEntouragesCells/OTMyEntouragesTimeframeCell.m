//
//  OTMyEntouragesTimeframeCell.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesTimeframeCell.h"
#import "OTDataSourceBehavior.h"
#import "OTMyEntourageTimeframeFilter.h"

#define TIMEFRAME_FONT_SIZE 15
#define TIMEFRAME_ACTIVE_FONT [UIFont fontWithName:@"SFUIText-Medium" size:TIMEFRAME_FONT_SIZE]
#define TIMEFRAME_INACTIVE_FONT [UIFont fontWithName:@"SFUIText-Light" size:TIMEFRAME_FONT_SIZE]

@implementation OTMyEntouragesTimeframeCell

- (void)configureWith:(OTMyEntourageFilter *)filter {
    OTMyEntourageTimeframeFilter *item = (OTMyEntourageTimeframeFilter *)filter;
    if(item.timeframeInHours == 30 * 24)
        [self activateButton:self.btn30Days withFilter:item];
    else if(item.timeframeInHours == 8 * 24)
        [self activateButton:self.btn8Days withFilter:item];
    else
        [self activateButton:self.btn1Day withFilter:item];
}

- (IBAction)activateButton:(UIButton *)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTMyEntourageTimeframeFilter *item = (OTMyEntourageTimeframeFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    [self activateButton:sender withFilter:item];
}

#pragma mark - private methods

- (void)activateButton:(UIButton *)sender withFilter:(OTMyEntourageTimeframeFilter *)filter {
    [self.btn1Day setSelected:self.btn1Day == sender];
    [self.btn8Days setSelected:self.btn8Days == sender];
    [self.btn30Days setSelected:self.btn30Days == sender];
    if(self.btn30Days.isSelected)
        filter.timeframeInHours = 30 * 24;
    else if(self.btn8Days.isSelected)
        filter.timeframeInHours = 8 * 24;
    else
        filter.timeframeInHours = 24;
    self.btn1Day.titleLabel.font = self.btn1Day == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
    self.btn8Days.titleLabel.font = self.btn8Days == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
    self.btn30Days.titleLabel.font = self.btn30Days == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
}

@end
