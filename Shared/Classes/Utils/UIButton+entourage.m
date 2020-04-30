//
//  UIButton+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <AFNetworking/UIButton+AFNetworking.h>

#import "UIButton+entourage.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"

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
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    self.enabled = NO;
    NSString *title = @"";
    UIColor *color = [OTAppAppearance iconColorForFeedItem:feedItem];
    
    if (isActive) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            self.enabled = YES;
            if ([feedItem.status isEqualToString:TOUR_STATUS_ONGOING]) {
                title = OTLocalizedString(@"ongoing");
            }
            else {
                title = OTLocalizedString(@"join_active");
            }
        } else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus]) {
                self.enabled = YES;
                title = OTLocalizedString(@"join_active");
            } else if ([JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
                self.enabled = YES;
                title = OTLocalizedString(@"join_pending");
            } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
                title = OTLocalizedString(@"join_rejected");
            } else {
                title = [NSString stringWithFormat:@"+ %@", OTLocalizedString(@"join_to_join")].uppercaseString;
            }
        }
    }
    else {
        title = OTLocalizedString(@"item_closed");
        if (![feedItem isOuting] && [feedItem.outcomeStatus boolValue]) {
            title = @"Succès";
            color = [ApplicationTheme shared].backgroundThemeColor;
        }
    }
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
}

#pragma mark - private methods

- (void)resizeStatusButton {
    for(NSLayoutConstraint *constraint in self.constraints)
        if(constraint.firstAttribute == NSLayoutAttributeWidth)
            constraint.constant = self.hidden ? 0 : statusButtonWidth;
}

@end
