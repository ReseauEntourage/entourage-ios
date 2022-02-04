//
//  OTMeetingCalloutViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTEncounter;

@interface OTMeetingCalloutViewController : UIViewController

@property (strong, nonatomic) OTEncounter *encounter;

- (void)configureWithEncouter:(OTEncounter *)encounter;

@end
