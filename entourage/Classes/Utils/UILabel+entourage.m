//
//  UILabel+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UILabel+entourage.h"
#import "OTFeedItemAuthor.h"
#import "OTTourPoint.h"
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"


@implementation UILabel (entourage)

- (void)setupAsStatusButtonForFeedItem:(OTFeedItem *)feedItem {
    bool isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    if(isActive) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            if([feedItem.status isEqualToString:TOUR_STATUS_ONGOING])
                [self setText:OTLocalizedString(@"ongoing")];
            else
                [self setText:OTLocalizedString(@"join_active")];
            [self setTextColor:[UIColor appOrangeColor]];
        } else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus]) {
                [self setText:OTLocalizedString(@"join_active")];
                [self setTextColor:[UIColor appOrangeColor]];
            } else if ([JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
                [self setText:OTLocalizedString(@"join_pending")];
                [self setTextColor:[UIColor appOrangeColor]];
            } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
                [self setText:OTLocalizedString(@"join_rejected")];
                [self setTextColor:[UIColor appTomatoColor]];
            } else {
                [self setText:OTLocalizedString(@"join_to_join")];
                [self setTextColor:[UIColor appGreyishColor]];
            }
        }
    }
    else {
        [self setText:OTLocalizedString(@"item_closed")];
        [self setTextColor:[UIColor appGreyishColor]];
    }
}

- (void)underline {
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:underlineAttribute];
}

@end
