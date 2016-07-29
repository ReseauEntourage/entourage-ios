//
//  OTGroupedTableSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTGroupedTableDataProviderBehavior.h"

@interface OTGroupedTableSourceBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OTGroupedTableDataProviderBehavior *dataProviderBehavior;

@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) NSArray *quickJumpList;

- (void)initialise;
- (id)getItemAtIndexPath:(NSIndexPath *)indexPath;

@end
