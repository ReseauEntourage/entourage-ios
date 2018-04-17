//
//  OTGuideDetailsViewController.h
//  entourage
//
//  Created by Mihai Ionescu on 05/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OTPoi.h"
#import "OTPoiCategory.h"

@interface OTGuideDetailsViewController : UIViewController

@property (nonatomic, strong) OTPoi *poi;
@property (nonatomic, strong) OTPoiCategory *category;

@end
