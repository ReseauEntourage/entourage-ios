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

#define JOINBUTTON_ACCEPTED     @"activeButton"
#define JOINBUTTON_NOTACCEPTED  @"joinButton"


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
    if ([tour.joinStatus isEqualToString:JOIN_ACCEPTED]) {
        [self setImage:[UIImage imageNamed:JOINBUTTON_ACCEPTED] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:JOINBUTTON_NOTACCEPTED] forState:UIControlStateNormal];
    }
}

@end
