//
//  OTEntourageAddressBookViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTGroupedTableSourceBehavior.h"
#import "OTGroupedTableDataProviderBehavior.h"

@interface OTEntourageInviteContactsViewController : UIViewController

@property (nonatomic, weak) IBOutlet OTGroupedTableSourceBehavior *groupedSource;
@property (nonatomic, weak) IBOutlet OTGroupedTableDataProviderBehavior *dataProvider;

@end
