//
//  UIButton+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"

@interface UIButton (entourage)

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString;

- (void)setupAsProfilePictureFromUrl:(NSString *)avatarURLString
                     withPlaceholder:(NSString *)placeholder;

- (void)setupWithStatus:(NSString*)status andJoinStatus:(NSString *)joinStatus;
//- (void)setupWithJoinStatusOfTour:(OTTour *)tour;

@end
