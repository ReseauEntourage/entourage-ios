//
//  OTTourCreatorViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 25/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTTourCreatorDelegate <NSObject>

@required
- (void)createTour:(NSString*)tourType;

@end

@interface OTTourCreatorViewController : UIViewController

@property (nonatomic, weak) id<OTTourCreatorDelegate> tourCreatorDelegate;

@end
