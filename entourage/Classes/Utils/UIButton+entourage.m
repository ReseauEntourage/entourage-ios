//
//  UIButton+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIButton+entourage.h"
#import "UIButton+AFNetworking.h"

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
    if (avatarURLString != nil && ![avatarURLString isKindOfClass:[NSNull class]]) {
        NSURL *url = [NSURL URLWithString:avatarURLString];
        UIImage *placeholderImage = [UIImage imageNamed:placeholder];
        [userImageButton setImageForState:UIControlStateNormal
                                  withURL:url
                         placeholderImage:placeholderImage];
    }

}

- (void)setupWithJoinStatusOfTour:(OTTour *)tour {
    self.hidden = [TOUR_STATUS_FREEZED isEqualToString:tour.status];
    if ([tour.joinStatus isEqualToString:JOIN_ACCEPTED]) {
        [self setImage:[UIImage imageNamed:JOINBUTTON_ACCEPTED] forState:UIControlStateNormal];
    } else  if ([tour.joinStatus isEqualToString:JOIN_PENDING]) {
        [self setImage:[UIImage imageNamed:JOINBUTTON_PENDING] forState:UIControlStateNormal];
    } else if ([tour.joinStatus isEqualToString:JOIN_REJECTED]) {
        [self setImage:[UIImage imageNamed:JOINBUTTON_REJECTED] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:JOINBUTTON_NOTREQUESTED] forState:UIControlStateNormal];
    }
}

@end
