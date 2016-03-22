//
//  UILabel+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"

@interface UILabel (entourage)

- (void)setupWithTypeAndAuthorOfTour:(OTTour*)tour;
- (void)setupWithTimeAndLocationOfTour:(OTTour *)tour;
- (void)setupWithJoinStatusOfTour:(OTTour *)tour;

@end
