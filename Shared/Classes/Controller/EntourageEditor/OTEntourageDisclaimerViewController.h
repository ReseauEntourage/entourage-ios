//
//  OTEntourageDisclaimerViewController.h
//  entourage
//
//  Created by sergiu.buceac on 06/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTDisclaimerViewController.h"

@interface OTEntourageDisclaimerViewController : UIViewController

@property (nonatomic, weak) id<DisclaimerDelegate> disclaimerDelegate;
@property (nonatomic) BOOL isForCreatingEvent;

@end
