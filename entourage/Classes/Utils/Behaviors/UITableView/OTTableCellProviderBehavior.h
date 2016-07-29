//
//  OTTableCellProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTTableDataSourceBehavior.h"

@interface OTTableCellProviderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath;

@end
