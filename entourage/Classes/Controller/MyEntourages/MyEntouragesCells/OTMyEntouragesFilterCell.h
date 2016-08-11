//
//  OTMyEntouragesFilterCell.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMyEntourageFilter.h"
#import "OTMyEntouragesFiltersTableDataSource.h"

@interface OTMyEntouragesFilterCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UISwitch *swtActive;
@property (nonatomic, weak) IBOutlet OTMyEntouragesFiltersTableDataSource* tableDataSource;

- (void)configureWith:(OTMyEntourageFilter *)filter;

@end
