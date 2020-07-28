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
#import "entourage-Swift.h"

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

+ (NSString *)statusTitleForItem:(OTFeedItem*)feedItem {
    OTUser*currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    NSString *title = nil;
    if (isActive) {
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            if ([feedItem.status isEqualToString:TOUR_STATUS_ONGOING]) {
                title = OTLocalizedString(@"ongoing");
            }
            else {
                title = OTLocalizedString(@"join_active");
            }
        }
        else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus])
                title = OTLocalizedString(@"join_active_other");
            else if ([JOIN_PENDING isEqualToString:feedItem.joinStatus])
                title = OTLocalizedString(@"join_pending");
            else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus])
                title = OTLocalizedString(@"join_rejected");
            else {
                title = OTLocalizedString(@"join_to_join");
            }
        }
    }
    else {
        title = OTLocalizedString(@"item_closed");
        if (![feedItem isOuting] && [feedItem.outcomeStatus boolValue]) {
            title = @"Succès !";
        }
    }
    
    return title;
}

#pragma mark - private methods

- (void)updateTextButtonAndJoin {
    self.isJoinPossible = NO;
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    NSString *title = [OTStatusBehavior statusTitleForItem:self.feedItem];
    
    if (self.isActive) {
        if (self.feedItem.author.uID.intValue == self.currentUser.sid.intValue)
            if([self.feedItem.status isEqualToString:TOUR_STATUS_ONGOING])
                [self updateTextButtonWithText:title andColor:color];
            else
                [self updateTextButtonWithText:title andColor:color];
        else {
            if ([JOIN_ACCEPTED isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:title andColor:color];
            else if ([JOIN_PENDING isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:title andColor:color];
            else if ([JOIN_REJECTED isEqualToString:self.feedItem.joinStatus])
                [self updateTextButtonWithText:title andColor:[UIColor appTomatoColor]];
            else {
                [self updateTextButtonWithText:title andColor:[UIColor appGreyishColor]];
                self.isJoinPossible = YES;
            }
        }
    }
    else {
        if (![self.feedItem isOuting] && [self.feedItem.outcomeStatus boolValue]) {
            [self updateTextButtonWithText:title andColor:[UIColor appGreyishColor]];
        } else {
            [self updateTextButtonWithText:title andColor:color];
        }
    }
}

- (void)updateTextButtonWithText:(NSString *)text andColor:(UIColor *)color {
    [self.btnStatus setTitle:text forState:UIControlStateNormal];
    [self.btnStatus setTitleColor:color forState:UIControlStateNormal];
    [self.statusLineMarker setBackgroundColor:color];
}

@end
