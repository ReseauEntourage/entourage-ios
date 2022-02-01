//
//  OTMembersDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMembersDataSource.h"
#import "OTFeedItemFactory.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"
#import "OTFeedItemFactory.h"

@implementation OTMembersDataSource

- (void)loadDataFor:(OTFeedItem *)feedItem {
    [SVProgressHUD show];
    NSMutableArray *newItems = [NSMutableArray new];
    
    if ([feedItem isOuting]) {
        // Event creator row
        feedItem.identifierTag = @"eventAuthorInfo";
        [newItems addObject:feedItem.copy];
        
        // Event info row
        feedItem.identifierTag = @"eventInfo";
        [newItems addObject:feedItem.copy];
    }
    
    // Map row
    feedItem.identifierTag = @"feedLocation";
    [newItems addObject:feedItem.copy];
    
    // Description row
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    if ([description length] > 0) {
        feedItem.identifierTag = @"feedDescription";
        [newItems addObject:feedItem.copy];
    }
    
    // Members count row
    feedItem.identifierTag = @"membersCount";
    [newItems addObject:feedItem.copy];
    
    // Invite friend row
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:feedItem] getStateInfo];
    if ([stateInfo canChangeEditState] && [stateInfo canInvite]) {
        // Invite item
        feedItem.identifierTag = @"inviteFriend";
        [newItems addObject:feedItem.copy];
    }
    
    [self refreshTable:newItems];
    
    // Member/user rows
    [[[OTFeedItemFactory createFor:feedItem] getMessaging] getFeedItemUsersWithStatus:JOIN_ACCEPTED success:^(NSArray *items) {
        
        [newItems addObjectsFromArray:items];
        [self refreshTable:newItems];
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *failure) {
        [SVProgressHUD dismiss];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entourageUpdated:) name:kNotificationEntourageChanged
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)refreshTable:(NSArray *)newItems {
    [self updateItems:newItems];
    [self.tableDataSource refresh];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSInteger)indexOfDescriptionItem {
    for (OTFeedItem *item in self.items) {
        if ([item.identifierTag isEqualToString:@"feedDescription"]) {
            return [self.items indexOfObject:item];
        }
    }
    
    return -1;
}

- (void)entourageUpdated:(NSNotification *)notification {
    OTFeedItem *feedItem = (OTFeedItem *)[notification.userInfo objectForKey:kNotificationEntourageChangedEntourageKey];
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    
    if ([description length] > 0) {
        if ([self indexOfDescriptionItem] > 0) {
            feedItem.identifierTag = @"feedDescription";
            [self.items replaceObjectAtIndex:[self indexOfDescriptionItem] withObject:feedItem.copy];
            [self.tableDataSource refresh];
        }
    }
}

@end
