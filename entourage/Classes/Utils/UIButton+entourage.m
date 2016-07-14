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

#define DEFAULT_IMAGE @"userSmall"

#define JOINBUTTON_NOTREQUESTED @"joinButton"
#define JOINBUTTON_PENDING      @"pendingRequestButton"
#define JOINBUTTON_ACCEPTED     @"activeButton"
#define JOINBUTTON_REJECTED     @"refusedRequestButton"


@implementation UIButton (entourage)

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString
{
    [self setupAsProfilePictureFromUrl:avatarURLString withPlaceholder:DEFAULT_IMAGE];
}

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString
                     withPlaceholder:(NSString *)placeholder
{
    __weak UIButton *userImageButton = self;
    userImageButton.layer.cornerRadius = userImageButton.bounds.size.height/2.f;
    userImageButton.clipsToBounds = YES;
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
    self.hidden = ![FEEDITEM_STATUS_ACTIVE isEqualToString:[feedItem newsfeedStatus]];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
        //
        [self setImage:[UIImage imageNamed:JOINBUTTON_ACCEPTED] forState:UIControlStateNormal];
    } else {
        if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus]) {
            [self setImage:[UIImage imageNamed:JOINBUTTON_ACCEPTED] forState:UIControlStateNormal];
        } else if ([JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
            [self setImage:[UIImage imageNamed:JOINBUTTON_PENDING] forState:UIControlStateNormal];
        } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
           [self setImage:[UIImage imageNamed:JOINBUTTON_REJECTED] forState:UIControlStateNormal];
        } else {
           [self setImage:[UIImage imageNamed:JOINBUTTON_NOTREQUESTED] forState:UIControlStateNormal];
        }
    }
}

@end
