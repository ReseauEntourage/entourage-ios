//
//  UIButton+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIButton+entourage.h"
#import "UIButton+AFNetworking.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"

#define DEFAULT_IMAGE @"userSmall"

#define JOINBUTTON_NOTREQUESTED @"joinButton"
#define JOINBUTTON_PENDING      @"pendingRequestButton"
#define JOINBUTTON_ACCEPTED     @"activeButton"
#define JOINBUTTON_REJECTED     @"refusedRequestButton"

@implementation UIButton (entourage)

#define statusButtonWidth 45

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString
{
    [self setupAsProfilePictureFromUrl:avatarURLString withPlaceholder:DEFAULT_IMAGE];
}

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString
                     withPlaceholder:(NSString *)placeholder
{
    __weak UIButton *userImageButton = self;
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    if (avatarURLString != nil && [avatarURLString class] != [NSNull class] && avatarURLString.length > 0) {
        NSURL *url = [NSURL URLWithString:avatarURLString];
        [userImageButton setImageForState:UIControlStateNormal
                                  withURL:url
                         placeholderImage:placeholderImage];
    }
    else
        [userImageButton setImage:placeholderImage forState:UIControlStateNormal];
}

- (void)setupAsStatusButtonForFeedItem:(OTFeedItem *)feedItem {
    self.hidden = ![[[OTFeedItemFactory createFor:feedItem] getUI] isStatusBtnVisible];
    [self resizeStatusButton];
    [self setImage:[UIImage imageNamed:JOINBUTTON_ACCEPTED] forState:UIControlStateNormal];
}

- (void)setupAsStatusTextButtonForFeedItem:(OTFeedItem *)feedItem {
    bool isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    if(isActive) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            if([feedItem.status isEqualToString:TOUR_STATUS_ONGOING])
                [self setTitle:OTLocalizedString(@"ongoing") forState:UIControlStateNormal];
            else
                [self setTitle:OTLocalizedString(@"join_active") forState:UIControlStateNormal];
            [self setTitleColor:[UIColor appOrangeColor] forState:UIControlStateNormal];
        } else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus]) {
                [self setTitle:OTLocalizedString(@"join_active") forState:UIControlStateNormal];
                [self setTitleColor:[UIColor appOrangeColor] forState:UIControlStateNormal];
            } else if ([JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
                [self setTitle:OTLocalizedString(@"join_pending") forState:UIControlStateNormal];
                [self setTitleColor:[UIColor appOrangeColor] forState:UIControlStateNormal];
            } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
                [self setTitle:OTLocalizedString(@"join_rejected") forState:UIControlStateNormal];
                [self setTitleColor:[UIColor appTomatoColor] forState:UIControlStateNormal];
            } else {
                [self setTitle:OTLocalizedString(@"join_to_join") forState:UIControlStateNormal];
                [self setTitleColor:[UIColor appGreyishColor] forState:UIControlStateNormal];
            }
        }
    }
    else {
        [self setTitle:OTLocalizedString(@"item_closed") forState:UIControlStateNormal];
        [self setTitleColor:[UIColor appGreyishColor] forState:UIControlStateNormal];
    }
}

//- (void)underline {
//    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
//    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:underlineAttribute];
//}

#pragma mark - private methods

- (void)resizeStatusButton {
    for(NSLayoutConstraint *constraint in self.constraints)
        if(constraint.firstAttribute == NSLayoutAttributeWidth)
            constraint.constant = self.hidden ? 0 : statusButtonWidth;
}

@end
