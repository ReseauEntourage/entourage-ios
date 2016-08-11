//
//  OTMyEntouragesFilterCellBase.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMyEntourageFilter.h"
#import "OTMyEntouragesFiltersTableDataSource.h"

@interface OTMyEntouragesFilterCellBase : UITableViewCell

@property (nonatomic, weak) IBOutlet OTMyEntouragesFiltersTableDataSource* tableDataSource;

- (void)configureWith:(OTMyEntourageFilter *)filter;

@end
