//
//  OTMessageTableDelegateBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTMessageTableDataSourceBehavior.h"

@interface OTMessageTableDelegateBehavior : OTBehavior <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet OTMessageTableDataSourceBehavior *tableDataSource;

@end
