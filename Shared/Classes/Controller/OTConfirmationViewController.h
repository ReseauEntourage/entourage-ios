//
//  OTConfirmationViewController.h
//  entourage
//
//  Created by Nicolas Telera on 16/11/2015.
//  Copyright © 2015 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTTour;

@protocol OTConfirmationViewControllerDelegate <NSObject>

- (void)tourSent:(OTTour*)tour;
@optional
- (void)resumeTour;
- (void)tourCloseError;

@end

@interface OTConfirmationViewController : UIViewController

@property(nonatomic, weak) id<OTConfirmationViewControllerDelegate> delegate;

- (void)configureWithTour:(OTTour *)currentTour
       andEncountersCount:(NSNumber *)encountersCount;

@end
