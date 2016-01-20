//
//  OTSWRevealView.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTSWRevealViewController.h"

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
    
    [[OTAuthService new] checkVersionWithSuccess:^(BOOL status) {
        if (status) {
            NSLog(@"%@", @"200");
        } else {
            NSLog(@"%@", @"426");
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];

	if (![[NSUserDefaults standardUserDefaults] currentUser])
	{
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		OTStartupViewController *startupViewController = [storyboard instantiateViewControllerWithIdentifier:@"OTStartupNavigationViewControllerIdentifier"];
		[self presentViewController:startupViewController animated:YES completion:nil];
	}
}

@end
