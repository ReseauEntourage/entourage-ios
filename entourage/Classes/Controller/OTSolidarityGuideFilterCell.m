//
//  OTSolidarityGuideFilterCell.m
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilterCell.h"

@implementation OTSolidarityGuideFilterCell

- (void)configureWith:(OTSolidarityGuideFilterItem*)filter {
    self.lblTitle.text = filter.title;
    [self.swtActive setOn:filter.active animated:YES];
    self.image.image = [UIImage imageNamed:filter.image];
}

@end
