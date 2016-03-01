//
//  OTTourJoinRequestViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTTourJoinRequestDelegate  <NSObject>

- (void)dismissTourJoinRequestController;

@end

@interface OTTourJoinRequestViewController : UIViewController

@property (nonatomic, weak) id<OTTourJoinRequestDelegate> tourJoinRequestDelegate;

@end
