//
//  OTEntourageAddressBookViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTDataSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTFeedItem.h"

@interface OTEntourageInviteContactsViewController : UIViewController

@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;

@property (nonatomic, strong) OTFeedItem *feedItem;

@end
