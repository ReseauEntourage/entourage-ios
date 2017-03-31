//
//  OTSolidarityGuideFilterCell.m
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilterCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTSolidarityGuideFilterCell

- (void)configureWith:(OTSolidarityGuideFilterItem*)filter {
    self.lblTitle.text = filter.title;
    [self.swtActive setOn:filter.active animated:YES];
    self.image.image = [UIImage imageNamed:filter.image];
}

- (IBAction)changeActive:(id)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTSolidarityGuideFilterItem *item = (OTSolidarityGuideFilterItem *)[self.tableDataSource getItemAtIndexPath:indexPath];
    UISwitch *swtControl = (UISwitch *)sender;
    item.active = swtControl.isOn;
}


@end
