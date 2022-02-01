//
//  OTTutorialViewController.h
//  entourage
//
//  Created by sergiu buceac on 2/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTTutorialViewController : UIPageViewController

-(void)enableScrolling:(BOOL)enabled;
-(void)showPreviousViewController:(UIViewController *)viewController;
-(void)showNextViewController:(UIViewController *)viewController;

@end
