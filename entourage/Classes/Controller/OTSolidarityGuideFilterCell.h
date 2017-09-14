//
//  OTSolidarityGuideFilterCell.h
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFiltersTableDataSource.h"
#import "OTSolidarityGuideFilterItem.h"

@interface OTSolidarityGuideFilterCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UISwitch *swtActive;
@property (nonatomic, weak) IBOutlet UIImageView *image;

@property (nonatomic, weak) IBOutlet OTSolidarityGuideFiltersTableDataSource* tableDataSource;

- (void)configureWith:(OTSolidarityGuideFilterItem *)filter;

@end
