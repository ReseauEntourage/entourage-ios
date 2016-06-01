//
//  UILabel+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UILabel+entourage.h"
#import "OTTourAuthor.h"
#import "OTTourPoint.h"
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"


@implementation UILabel (entourage)

- (void)setupWithTypeAndAuthorOfTour:(OTTour*)tour {
    OTTourAuthor *author = tour.author;
    
    NSString *tourType = tour.type;
    if ([tourType isEqualToString:@"barehands"]) {
        tourType = @"sociale";
    } else     if ([tourType isEqualToString:@"medical"]) {
        tourType = @"médicale";
    } else if ([tourType isEqualToString:@"alimentary"]) {
        tourType = @"distributive";
    }
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Mauraude %@ par ", tourType] attributes:lightAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:author.displayName attributes:boldAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    self.attributedText = typeByNameAttrString;
}

- (void)setupAsTypeByNameFromEntourage:(OTEntourage*)ent {
    NSString *authorName = ent.author.displayName;
    
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ par ", [ent displayType].capitalizedString] attributes:lightAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:authorName attributes:boldAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    self.attributedText = typeByNameAttrString;
}

- (void)setupWithTime:(NSDate*)date andLocation:(CLLocation*)location {
    // dateString - location
    NSString *dateString = nil;
    if (date != nil) {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:[NSDate date]];
        [timeIntervalFormatter setUsesIdiomaticDeicticExpressions:YES];
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

- (void)setupWithTimeAndLocationOfTour:(OTTour *)tour {
    
    // dateString - location
    NSString *dateString = nil;
    if (tour.creationDate != nil) {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSTimeInterval timeInterval = [tour.creationDate timeIntervalSinceDate:[NSDate date]];
        [timeIntervalFormatter setUsesIdiomaticDeicticExpressions:YES];
        dateString = [timeIntervalFormatter stringForTimeInterval:timeInterval];
        self.text = dateString;
    }
    OTTourPoint *startPoint = tour.tourPoints.firstObject;
    CLLocation *loc =  [[CLLocation alloc] initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
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

- (void)setupWithStatus:(NSString *)status andJoinStatus:(NSString*)joinStatus {
    self.hidden = [TOUR_STATUS_CLOSED isEqualToString:status];
    
    if ([joinStatus isEqualToString:JOIN_ACCEPTED]) {
        [self setText:@"Actif"];
        [self setTextColor:[UIColor appOrangeColor]];
    } else {
        if ([joinStatus isEqualToString:JOIN_PENDING]) {
            [self setText:@"Demande en attente"];
            [self setTextColor:[UIColor appOrangeColor]];
        } else if ([joinStatus isEqualToString:JOIN_REJECTED]) {
            [self setText:@"Demande rejetée"];
            [self setTextColor:[UIColor appTomatoColor]];
        } else {
            [self setText:@"Je rejoins"];
            [self setTextColor:[UIColor appGreyishColor]];
        }
    }
}



@end
