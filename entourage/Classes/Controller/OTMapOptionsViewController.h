//
//  OTMapOptionsViewController.h
//  entourage
//
//  Created by Mihai Ionescu on 04/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTMapOptionsDelegate <NSObject>

- (void)createTour;
- (void)createDemande;
- (void)createContribution;

- (void)togglePOI;
- (void)dismissMapOptions;

@end

@interface OTMapOptionsViewController : UIViewController

@property (nonatomic, weak) id<OTMapOptionsDelegate> mapOptionsDelegate;
@property (nonatomic, assign) CGPoint fingerPoint;

- (void)setIsPOIVisible:(BOOL)POIVisible;

@end
