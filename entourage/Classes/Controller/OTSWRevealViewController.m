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

#import "OTLoginViewController.h"

// Model
#import "OTUser.h"

@implementation OTSWRevealViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// To disconnect the user
//		[[NSUserDefaults standardUserDefaults] setUserMail:nil];
	//	[[NSUserDefaults standardUserDefaults] setUserSid:nil];

	if (![[NSUserDefaults standardUserDefaults] userMail]) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		OTLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"OTLoginViewControllerIdentifier"];
		[self presentViewController:loginViewController animated:YES completion:nil];
	}
}

@end
