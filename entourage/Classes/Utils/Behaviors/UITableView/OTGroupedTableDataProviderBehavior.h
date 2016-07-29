//
//  OTGroupedTableDataProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
@class OTGroupedTableSourceBehavior;

@interface OTGroupedTableDataProviderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet OTGroupedTableSourceBehavior *groupedSource;

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath;
- (void)refreshSource:(NSArray *)items;

@end
