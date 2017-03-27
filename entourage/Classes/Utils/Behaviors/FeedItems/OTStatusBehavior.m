//
//  OTStatusBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStatusBehavior.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "OTTour.h"
#import "OTStatusChangedBehavior.h"

#define BUTTON_NOTREQUESTED @"joinButton"
#define BUTTON_PENDING      @"pendingRequestButton"
#define BUTTON_ACCEPTED     @"activeButton"
#define BUTTON_REJECTED     @"refusedRequestButton"

@interface OTStatusBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, assign) BOOL isActive;

@end

@implementation OTStatusBehavior

- (void)initialize {
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)updateWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
    self.isActive = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] isActive];
    self.btnStatus.enabled = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] canCancelJoinRequest];
    [self.btnStatus addTarget:self.statusChangedBehavior action:@selector(startChangeStatus) forControlEvents:UIControlEventTouchUpInside];
    [self updateTextButtonAndJoin];
}

#pragma mark - private methods

- (void)updateTextButtonAndJoin {
    self.isJoinPossible = NO;
    if(self.isActive) {
        if (self.feedItem.author.uID.intValue == self.currentUser.sid.intValue)
            if([self.feedItem.status isEqualToString:TOUR_STATUS_ONGOING])
                [self updateTextButtonWithText:OTLocalizedString(@"ongoing") andColor:[UIColor appOrangeColor]];
            else
                [self updateTextButtonWithText:OTLocalizedString(@"join_active") andColor:[UIColor appOrangeColor]];
        else {
            if ([JOIN_ACCEPTED isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:OTLocalizedString(@"join_active") andColor:[UIColor appOrangeColor]];
            else if ([JOIN_PENDING isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:OTLocalizedString(@"join_pending") andColor:[UIColor appOrangeColor]];
            else if ([JOIN_REJECTED isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:OTLocalizedString(@"join_rejected") andColor:[UIColor appTomatoColor]];
            else {
                [self updateTextButtonWithText:OTLocalizedString(@"join_to_join") andColor:[UIColor appGreyishColor]];
                self.isJoinPossible = YES;
            }
        }
    }
    else
        [self updateTextButtonWithText:OTLocalizedString(@"item_closed") andColor:[UIColor appGreyishColor]];
}

- (void)updateTextButtonWithText:(NSString *)text andColor:(UIColor *)color {
    [self.btnStatus setTitle:text forState:UIControlStateNormal];
    [self.btnStatus setTitleColor:color forState:UIControlStateNormal];
    [self.statusLineMarker setBackgroundColor:color];
}

@end
