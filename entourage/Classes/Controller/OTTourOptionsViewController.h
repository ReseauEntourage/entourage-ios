//
//  OTTourOptionsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTOptionsViewController.h"

//@protocol OTTourOptionsDelegate <NSObject>
//
//- (void)createEncounter;
//- (void)togglePOI;
//- (void)dismissTourOptions;
//
//@end

@interface OTTourOptionsViewController : OTOptionsViewController

//@property(nonatomic, weak) id<OTTourOptionsDelegate> tourOptionsDelegate;
@property(nonatomic, assign) CGPoint c2aPoint;

- (void)setIsPOIVisible:(BOOL)isPOIVisible;

@end
