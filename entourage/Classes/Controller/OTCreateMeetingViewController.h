//
//  OTCreateMeetingViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

// Frameworks
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SpeechKit/SpeechKit.h>
#import "OTSpeechKitManager.h"

@class OTEncounter;

@protocol OTCreateMeetingViewControllerDelegate <NSObject>

- (void)encounterSent:(OTEncounter *)encounter;

@end

@interface OTCreateMeetingViewController : UIViewController <SpeechKitDelegate, SKRecognizerDelegate>

@property (nonatomic, weak) id<OTCreateMeetingViewControllerDelegate> delegate;
@property (nonatomic, strong) SKRecognizer *recognizer;
@property (nonatomic, strong) NSMutableArray *encounters;

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location;

@end
