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
#import "OTMyEntouragesFilterCellBase.h"

@interface OTMyEntouragesFilterCell : OTMyEntouragesFilterCellBase

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UISwitch *swtActive;

@end
