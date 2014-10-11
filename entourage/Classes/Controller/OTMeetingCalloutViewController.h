//
//  OTMeetingCalloutViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTEncounter;
@protocol OTMeetingCalloutViewControllerDelegate <NSObject>

- (void)dismissPopover;

@end

@interface OTMeetingCalloutViewController : UIViewController
@property (weak, nonatomic) id<OTMeetingCalloutViewControllerDelegate> delegate;

- (void)configureWithEncouter:(OTEncounter *)encounter;

@end
