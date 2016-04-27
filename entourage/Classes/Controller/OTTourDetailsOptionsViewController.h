//
//  OTTourDetailsOptionsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 08/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTour.h"

@protocol OTTourDetailsOptionsDelegate <NSObject>

@required
- (void)promptToCloseTour;

@end

@interface OTTourDetailsOptionsViewController : UIViewController

@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, weak) id<OTTourDetailsOptionsDelegate> delegate;

@end
