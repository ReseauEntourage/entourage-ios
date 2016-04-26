//
//  OTQuitTourViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"

@protocol OTTourQuitDelegate <NSObject>

@required
- (void)didQuitTour;

@end

@interface OTQuitTourViewController : UIViewController

@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, weak) id<OTTourQuitDelegate> tourQuitDelegate;

@end
