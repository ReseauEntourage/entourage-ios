//
//  OTDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
@class OTTableDataSourceBehavior;

@interface OTDataSourceBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (nonatomic, strong, readonly) NSMutableArray* items;

- (void)updateItems:(NSArray *)items;
- (void)loadData;
- (void)updateData;

@end
