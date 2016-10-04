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

- (void)setupWithTime:(NSDate*)date andLocation:(CLLocation*)location {
    // dateString - location
    NSString *dateString = nil;
    if (date != nil) {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.usesIdiomaticDeicticExpressions = YES;
        NSLocale *frLocale = [NSLocale localeWithLocaleIdentifier:@"fr"];
        [timeIntervalFormatter setLocale:frLocale];
        
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:[NSDate date]];
        dateString = [timeIntervalFormatter stringForTimeInterval:timeInterval];
        self.text = dateString;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.locality !=  nil) {
            if (dateString != nil) {
                self.text = [NSString stringWithFormat:@"%@ - %@", dateString, placemark.locality];
            } else {
                self.text = placemark.locality;
            }
        }
    }];

}

- (void)setupAsStatusButtonForFeedItem:(OTFeedItem *)feedItem {
    self.hidden = ![[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    
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

@end
