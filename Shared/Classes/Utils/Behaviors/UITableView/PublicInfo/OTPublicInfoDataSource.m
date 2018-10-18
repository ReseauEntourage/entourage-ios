//
//  OTPublicInfoDataSource.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicInfoDataSource.h"
#import "OTFeedItemFactory.h"
#import "OTTableDataSourceBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation OTPublicInfoDataSource

- (void)loadDataFor:(OTFeedItem *)feedItem {
    
    [SVProgressHUD show];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // Summary row
    OTFeedItem *summary = feedItem.copy;
    summary.identifierTag = @"summary";
    [items addObject:summary];
    
    if ([feedItem isOuting]) {
        // Event creator row
        OTFeedItem *eventAuthor = feedItem.copy;
        eventAuthor.identifierTag = @"eventAuthorInfo";
        [items addObject:eventAuthor];
        
        // Event info row
        OTFeedItem *eventInfo = feedItem.copy;
        eventInfo.identifierTag = @"eventInfo";
        [items addObject:eventInfo];
    }
    
    // Map row
    OTFeedItem *map = feedItem.copy;
    map.identifierTag = @"feedLocation";
    [items addObject:map];
    
    // Description row
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    if ([description length] > 0) {
        OTFeedItem *desc = feedItem.copy;
        desc.identifierTag = @"feedDescription";
        [items addObject:desc];
    }
    
    // Members count row
    OTFeedItem *membersCount = feedItem.copy;
    membersCount.identifierTag = @"membersCount";
    [items addObject:membersCount];
    
    [self refreshTable:items];
    
    // Invite friend row
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:feedItem] getStateInfo];
    BOOL shouldShowInviteOption = [stateInfo canChangeEditState] && [stateInfo canInvite];
    
    //EMA-2348
    shouldShowInviteOption = YES;
    
    if (shouldShowInviteOption) {
        // Invite item
        OTFeedItem *inviteFriend = feedItem.copy;
        inviteFriend.identifierTag = @"inviteFriend";
        [items addObject:inviteFriend];
    }
    
    // Member/user rows
    [[[OTFeedItemFactory createFor:feedItem] getMessaging] getFeedItemUsersWithStatus:JOIN_ACCEPTED success:^(NSArray *members) {
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [items addObjectsFromArray:members];
            [self updateItems:items withStatusCellForItem:feedItem];
            [self refreshTable:items];
            [SVProgressHUD dismiss];
        });
        
    } failure:^(NSError *failure) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self updateItems:items withStatusCellForItem:feedItem];
            [self refreshTable:items];
            [SVProgressHUD dismiss];
        });
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

- (void)updateItems:(NSMutableArray *)items withStatusCellForItem:(OTFeedItem*)feedItem {
    
    if ([feedItem.joinStatus isEqualToString:JOIN_NOT_REQUESTED] &&
        [feedItem.status isEqualToString:FEEDITEM_STATUS_CLOSED]) {
        return;
        
    }
    
    // EMA-2348
    if (![feedItem.joinStatus isEqualToString:JOIN_NOT_REQUESTED] ||
        [feedItem.status isEqualToString:FEEDITEM_STATUS_CLOSED]) {
        // Change status item
        OTFeedItem *changeStatus = feedItem.copy;
        changeStatus.identifierTag = @"changeStatus";
        [items addObject:changeStatus];
    }
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
