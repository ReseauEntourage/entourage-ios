//
//  OTCreateMeetingViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

// Voice Recognition Framework
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>

@class OTEncounter;

@interface OTCreateMeetingViewController : UIViewController <OEEventsObserverDelegate>

@property (nonatomic, strong) NSMutableArray *encounters;

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location;

@end
