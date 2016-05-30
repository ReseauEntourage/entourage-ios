//
//  OTMapOptionsViewController.h
//  entourage
//
//  Created by Mihai Ionescu on 04/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTOptionsViewController.h"


@interface OTMapOptionsViewController : OTOptionsViewController

@property (nonatomic, assign) CGPoint fingerPoint;

- (void)setIsPOIVisible:(BOOL)POIVisible;

@end
