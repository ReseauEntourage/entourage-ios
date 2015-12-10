//
//  OTConfirmationViewController.h
//  entourage
//
//  Created by Nicolas Telera on 16/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTTour;

@protocol OTConfirmationViewControllerDelegate <NSObject>

- (void)tourSent;
- (void)resumeTour;

@end

@interface OTConfirmationViewController : UIViewController

@property(nonatomic, weak) id<OTConfirmationViewControllerDelegate> delegate;

- (void)configureWithTour:(OTTour *)currentTour
       andEncountersCount:(NSNumber *)encountersCount
              andDuration:(NSTimeInterval)duration;

@end
