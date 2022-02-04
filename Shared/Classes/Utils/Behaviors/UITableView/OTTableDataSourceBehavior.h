//
//  OTTableDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTTour.h"
@class OTTableCellProviderBehavior;
@class OTDataSourceBehavior;


@interface OTTableDataSourceBehavior : OTBehavior <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableCellProviderBehavior *cellProvider;

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)refresh;

@end
