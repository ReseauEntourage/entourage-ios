//
//  OTMapViewController.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMeetingCalloutViewController.h"
#import "OTCreateMeetingViewController.h"
#import "OTConfirmationViewController.h"

@class MKMapView;

@interface OTMapViewController : UIViewController <OTMeetingCalloutViewControllerDelegate, OTCreateMeetingViewControllerDelegate, OTConfirmationViewControllerDelegate>



@end
