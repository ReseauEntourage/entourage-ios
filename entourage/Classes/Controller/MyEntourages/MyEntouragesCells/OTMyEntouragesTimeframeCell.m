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

@implementation OTMyEntouragesTimeframeCell

- (void)configureWith:(OTMyEntourageFilter *)filter {
    OTMyEntourageTimeframeFilter *item = (OTMyEntourageTimeframeFilter *)filter;
    if(item.timeframeInHours == 72)
        [self activateButton:self.btn3Days withFilter:item];
    else if(item.timeframeInHours == 48)
        [self activateButton:self.btn2Days withFilter:item];
    else
        [self activateButton:self.btn1Day withFilter:item];
}

- (IBAction)activateButton:(UIButton *)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTMyEntourageTimeframeFilter *item = (OTMyEntourageTimeframeFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    [self activateButton:sender withFilter:item];
}

#pragma mark - private methods

- (IBAction)activateButton:(UIButton *)sender withFilter:(OTMyEntourageTimeframeFilter *)filter {
    [self.btn1Day setSelected:self.btn1Day == sender];
    [self.btn2Days setSelected:self.btn2Days == sender];
    [self.btn3Days setSelected:self.btn3Days == sender];
    if(self.btn3Days.isSelected)
        filter.timeframeInHours = 72;
    else if(self.btn2Days.isSelected)
        filter.timeframeInHours = 48;
    else
        filter.timeframeInHours = 24;
}

@end
