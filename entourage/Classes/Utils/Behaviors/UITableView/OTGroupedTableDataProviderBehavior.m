//
//  OTGroupedTableDataProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTGroupedTableSourceBehavior.h"

@implementation OTGroupedTableDataProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    @throw @"Don't use base data provider directly";
}

- (void)refreshSource:(NSArray *)items {
    @throw @"Don't use base data provider directly";
}

@end
