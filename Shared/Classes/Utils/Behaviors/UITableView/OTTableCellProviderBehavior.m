//
//  OTTableCellProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTTableCellProviderBehavior.h"

@implementation OTTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    @throw @"Don't use base cell provider directly";
}

@end
