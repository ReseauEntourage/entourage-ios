//
//  OTTourViewController.h
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"

@interface OTTourViewController : UIViewController

@property (nonatomic, strong) OTTour *tour;

- (void)configureWithTour:(OTTour *)tour;

@end
