//
//  OTFeedItemInfoView.m
//  entourage
//
//  Created by Ciprian Habuc on 21/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemInfoView.h"

#import "OTEntourage.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "UILabel+entourage.h"
#import "UIButton+entourage.h"
#import "OTEntourageAnnotation.h"



#define FEEDITEM_MAP_TAG 1
#define FEEDITEM_DESCRIPTION_TAG 2
#define FEEDITEM_JOINBUTTON_TAG 3
#define FEEDITEM_JOINLABEL_TAG 4

@implementation OTFeedItemInfoView

- (void)setupWithFeedItem:(OTFeedItem *)feedItem {
    
    CLLocationCoordinate2D coordinate;
    if ([feedItem isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour*)feedItem;
        if (tour.tourPoints.count) {
            OTTourPoint *startPoint = tour.tourPoints[0];
            coordinate = CLLocationCoordinate2DMake(startPoint.latitude, startPoint.longitude);
        }
    } else {
        OTEntourage *ent = (OTEntourage *)feedItem;
        coordinate = ent.location.coordinate;
    }
    MKMapView *mapView = [self viewWithTag:FEEDITEM_MAP_TAG];
    mapView.delegate = self;
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        OTEntourageAnnotation *pointAnnotation = [[OTEntourageAnnotation alloc] initWithEntourage:(OTEntourage*)feedItem];
        [mapView addAnnotation:pointAnnotation];
    } else {
        [annotation setCoordinate:coordinate];
        [mapView addAnnotation:annotation];
    }

    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        UITextView *textView = [self viewWithTag:FEEDITEM_DESCRIPTION_TAG];
        textView.text = ((OTEntourage *)feedItem).desc;
    }
    
    UIButton *joinButton = [self viewWithTag:FEEDITEM_JOINBUTTON_TAG];
    [joinButton addTarget:self action:@selector(doJoinFeed:) forControlEvents:UIControlEventTouchUpInside];
    //[joinButton setupWithStatus:feedItem.status andJoinStatus:feedItem.joinStatus];
    [joinButton setupAsStatusButtonForFeedItem:feedItem];
    UILabel *joinLabel = [self viewWithTag:FEEDITEM_JOINLABEL_TAG];
    //[joinLabel setupWithStatus:feedItem.status andJoinStatus:feedItem.joinStatus];
    [joinLabel setupAsStatusButtonForFeedItem:feedItem];
}

- (void)doJoinFeed:(UIButton *)senderButton {
    if ([self.delegate respondsToSelector:@selector(doJoinTour)])
        [ self.delegate performSelector:@selector(doJoinTour)];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[OTEntourageAnnotation class]]) {
        OTEntourageAnnotation *entAnnotation = (OTEntourageAnnotation*)annotation;
        MKAnnotationView *annotationView = entAnnotation.annotationView;// [mapView dequeueReusableAnnotationViewWithIdentifier:@"EntourageAnnotation"];

        return annotationView;
    } else {
        return nil;
    }
}

@end
