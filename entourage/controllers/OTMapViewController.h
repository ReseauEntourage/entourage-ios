//
//  OTMapViewController.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;

@interface OTMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
