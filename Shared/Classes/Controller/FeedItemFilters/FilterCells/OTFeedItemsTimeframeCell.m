//
//  OTFeedItemsTimeframeCell.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemsTimeframeCell.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemTimeframeFilter.h"

#define TIMEFRAME_FONT_SIZE 15
#define TIMEFRAME_ACTIVE_FONT [UIFont fontWithName:@"SFUIText-Medium" size:TIMEFRAME_FONT_SIZE]
#define TIMEFRAME_INACTIVE_FONT [UIFont fontWithName:@"SFUIText-Light" size:TIMEFRAME_FONT_SIZE]

@implementation OTFeedItemsTimeframeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSArray *timeframes = self.tableDataSource.currentFilter.timeframes;
    [self setTextForTimeframe:timeframes[0] andButton:self.btnFirst];
    [self setTextForTimeframe:timeframes[1] andButton:self.btnSecond];
    [self setTextForTimeframe:timeframes[2] andButton:self.btnThird];
}

- (void)configureWith:(OTFeedItemFilter *)filter {
    OTFeedItemTimeframeFilter *item = (OTFeedItemTimeframeFilter *)filter;
    NSArray *timeframes = self.tableDataSource.currentFilter.timeframes;
    if([timeframes[0] intValue] == item.timeframeInHours)
        [self activateButton:self.btnFirst withFilter:item];
    else if([timeframes[1] intValue] == item.timeframeInHours)
        [self activateButton:self.btnSecond withFilter:item];
    else
        [self activateButton:self.btnThird withFilter:item];
}

- (IBAction)activateButton:(UIButton *)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTFeedItemTimeframeFilter *item = (OTFeedItemTimeframeFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    [self activateButton:sender withFilter:item];
    if(self.btnFirst.isSelected) {
        [OTLogger logEvent:@"ClickFilter1Value"];
    }
    else if(self.btnSecond.isSelected) {
        [OTLogger logEvent:@"ClickFilter2Value"];
    }
    else {
        [OTLogger logEvent:@"ClickFilter3Value"];
    }
}

#pragma mark - private methods

- (void)activateButton:(UIButton *)sender withFilter:(OTFeedItemTimeframeFilter *)filter {
    [self.btnFirst setSelected:self.btnFirst == sender];
    [self.btnSecond setSelected:self.btnSecond == sender];
    [self.btnThird setSelected:self.btnThird == sender];
    NSArray *timeframes = self.tableDataSource.currentFilter.timeframes;
    if(self.btnFirst.isSelected) {
        filter.timeframeInHours = [timeframes[0] intValue];
    }
    else if(self.btnSecond.isSelected) {
        filter.timeframeInHours = [timeframes[1] intValue];
    }
    else {
        filter.timeframeInHours = [timeframes[2] intValue];
    }
    self.btnFirst.titleLabel.font = self.btnFirst == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
    self.btnSecond.titleLabel.font = self.btnSecond == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
    self.btnThird.titleLabel.font = self.btnThird == sender ? TIMEFRAME_ACTIVE_FONT : TIMEFRAME_INACTIVE_FONT;
}

- (void)setTextForTimeframe:(NSNumber *)timeframe andButton:(UIButton *)button {
    NSString *title = OTLocalizedString(@"24H");
    if(timeframe.intValue > 24)
        title = [NSString stringWithFormat:@"%dJ", timeframe.intValue / 24];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
}

@end
