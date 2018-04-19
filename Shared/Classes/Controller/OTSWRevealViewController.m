//
//  OTSWRevealView.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTSWRevealViewController.h"

//Util
#import "UIStoryboard+entourage.h"

// Helper
#import "NSUserDefaults+OT.h"

//#import "OTLoginViewController.h"
#import "OTStartupViewController.h"

// Model
#import "OTUser.h"

// Service
#import "OTAuthService.h"

// Loader
#import "SVProgressHUD.h"

@implementation OTSWRevealViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self customizeSlideOutMenu];
    
	if (![[NSUserDefaults standardUserDefaults] currentUser])
	{
        [OTAppConfiguration navigateToStartupScreen];
	}
}

- (void)customizeSlideOutMenu {
    self.rearViewRevealWidth = [UIScreen mainScreen].bounds.size.width + 10;// how much of the menu is shown (default 260.0)
    
    // TOGGLING OVERDRAW: Configure the overdraw appearance of the content view while dragging it
    self.rearViewRevealOverdraw = 0.0f; // how much of an overdraw can occur when dragging further than 'rearViewRevealWidth' (default 60.0)
    self.bounceBackOnOverdraw = NO; // If YES the controller will bounce to the Left position when dragging further than 'rearViewRevealWidth' (default YES)
    
    // TOGGLING MENU DISPLACEMENT: how much displacement is applied to the menu when animating or dragging the content
    self.rearViewRevealDisplacement = 60.0f; // (default 40.0)
    
    // TOGGLING ANIMATION: Configure the animation while the menu gets hidden
    self.toggleAnimationType = SWRevealToggleAnimationTypeSpring; // Animation type (SWRevealToggleAnimationTypeEaseOut or SWRevealToggleAnimationTypeSpring)
    //self.toggleAnimationDuration = 1.0f; // Duration for the revealToggle animation (default 0.25)
    self.springDampingRatio = 1.0f; // damping ratio if SWRevealToggleAnimationTypeSpring (default 1.0)
    
    // SHADOW: Configure the shadow that appears between the menu and content views
    //self.frontViewShadowRadius = 10.0f; // radius of the front view's shadow (default 2.5)
    //self.frontViewShadowOffset = CGSizeMake(0.0f, 2.5f); // radius of the front view's shadow offset (default {0.0f,2.5f})
    self.frontViewShadowOpacity = 0.8f; // front view's shadow opacity (default 1.0)
    self.frontViewShadowColor = [UIColor colorWithRed:239 green:239 blue:244 alpha:0.8]; // front view's shadow color (default blackColor)
}

@end
