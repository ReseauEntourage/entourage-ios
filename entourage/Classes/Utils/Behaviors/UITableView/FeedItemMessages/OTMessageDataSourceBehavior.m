//
//  OTMessageDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageDataSourceBehavior.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"

@implementation OTMessageDataSourceBehavior

- (void)acceptJoin:(OTFeedItemJoiner *)joiner atPath:(NSIndexPath *)path {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:joiner.feedItem] getJoiner] accept:joiner success:^() {
        [SVProgressHUD dismiss];
        joiner.status = JOIN_ACCEPTED;
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"join_item_failed")];
    }];
}

- (void)rejectJoin:(OTFeedItemJoiner *)joiner atPath:(NSIndexPath *)path {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:joiner.feedItem] getJoiner] reject:joiner success:^() {
        [SVProgressHUD dismiss];
        [self.items removeObject:joiner];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"join_item_failed")];
    }];
}

#pragma mark - private methods

@end
