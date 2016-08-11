//
//  OTMyEntouragesFilterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFilterCell.h"
#import "OTMyEntourageFilter.h"
#import "OTDataSourceBehavior.h"

@implementation OTMyEntouragesFilterCell

- (void)configureWith:(OTMyEntourageFilter *)filter {
    self.lblTitle.text = filter.title;
    [self.swtActive setOn:filter.active animated:YES];
}

- (IBAction)changeActive:(id)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTMyEntourageFilter *item = (OTMyEntourageFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    UISwitch *swtControl = (UISwitch *)sender;
    item.active = swtControl.isOn;
}

@end
