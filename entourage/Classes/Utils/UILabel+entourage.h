//
//  UILabel+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"
#import "OTEntourage.h"
#import <CoreLocation/CoreLocation.h>

@interface UILabel (entourage)

- (void)setupWithTypeAndAuthorOfTour:(OTTour*)tour;
- (void)setupWithTime:(NSDate*)date andLocation:(CLLocation*)location;
//- (void)setupWithStatus:(NSString *)status andJoinStatus:(NSString*)joinStatus;
- (void)setupAsStatusButtonForFeedItem:(OTFeedItem *)feedItem;

- (void)setupAsTypeByNameFromEntourage:(OTEntourage*)ent;

@end
