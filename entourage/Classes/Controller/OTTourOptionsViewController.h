//
//  OTTourOptionsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTTourOptionsDelegate <NSObject>

- (void)createEncounter;
- (void)dismissTourOptions;

@end

@interface OTTourOptionsViewController : UIViewController

@property(nonatomic, weak) id<OTTourOptionsDelegate> tourOptionsDelegate;
@property(nonatomic, assign) CGPoint c2aPoint;

@end
