//
//  OTInviteContactsViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTDataSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTFeedItem.h"
#import "OTInviteSourceViewController.h"

@interface OTInviteContactsViewController : UIViewController

@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<InviteSuccessDelegate> delegate;

@end
