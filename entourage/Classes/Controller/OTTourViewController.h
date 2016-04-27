//
//  OTTourViewController.h
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"
// Frameworks
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include <SpeechKit/SpeechKit.h>

#import "OTSpeechKitManager.h"

@protocol OTTourTimelineDelegate <NSObject>

@required
- (void)promptToCloseTour;

@end

@interface OTTourViewController : UIViewController <SpeechKitDelegate, SKRecognizerDelegate>

@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) SKRecognizer *recognizer;
@property (nonatomic, weak) id<OTTourTimelineDelegate> delegate;

- (void)configureWithTour:(OTTour *)tour;

@end
