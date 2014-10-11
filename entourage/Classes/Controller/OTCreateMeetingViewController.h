//
//  OTCreateMeetingViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@class OTEncounter;

@protocol OTCreateMeetingViewControllerDelegate <NSObject>

- (void)dismissPopoverWithEncounter:(OTEncounter *)encounter;

@end

@interface OTCreateMeetingViewController : UIViewController
@property (weak, nonatomic) id<OTCreateMeetingViewControllerDelegate> delegate;

- (void)configureWithLocation:(CLLocationCoordinate2D)location;

@end
