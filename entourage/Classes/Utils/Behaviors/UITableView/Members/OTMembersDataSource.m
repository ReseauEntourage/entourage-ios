//
//  OTMembersDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersDataSource.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"

@implementation OTMembersDataSource

- (void)loadDataFor:(OTFeedItem *)feedItem {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:feedItem] getMessaging] getFeedItemUsersWithStatus:JOIN_ACCEPTED success:^(NSArray *items) {
        self.lblMemberCount.text = [NSString stringWithFormat:OTLocalizedString(@"member_count"), items.count];
        [self updateItems:items];
        [self.tableDataSource refresh];
        [SVProgressHUD dismiss];
    } failure:^(NSError *failure) {
        [SVProgressHUD dismiss];
    }];
}

@end
