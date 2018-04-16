//
//  OTCalloutViewController.h
//  entourage
//
//  Created by Guillaume Lagorce on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTPoi;

@protocol OTCalloutViewControllerDelegate <NSObject>

- (void)dismissPopover;

@end

@interface OTCalloutViewController : UIViewController

@property (weak, nonatomic) id<OTCalloutViewControllerDelegate> delegate;

- (void)configureWithPoi:(OTPoi *)poi;

@end
