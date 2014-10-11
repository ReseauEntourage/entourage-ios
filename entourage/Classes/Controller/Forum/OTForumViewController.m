//
//  OTForumViewController.m
//  entourage
//
//  Created by Mathieu Hausherr on 11/10/14.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTForumViewController.h"

// Controller
#import "UIViewController+menu.h"

// Utils
#import <uservoice-iphone-sdk/UserVoice.h>
#import "NSUserDefaults+OT.h"

#import "OTUser.h"

@interface OTForumViewController ()

@end

@implementation OTForumViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self createMenuButton];
}

- (IBAction)launchForum:(id)sender
{
	// Set this up once when your application launches
	UVConfig *config = [UVConfig configWithSite:@"entourage-social.uservoice.com"];

	config.showContactUs = NO;
	config.showKnowledgeBase = NO;
	config.forumId = 268709;
	NSString *userMail = [[NSUserDefaults standardUserDefaults].currentUser email];
	[config identifyUserWithEmail:userMail name:userMail guid:userMail];
	[UserVoice initialize:config];

	// Call this wherever you want to launch UserVoice
	[UserVoice presentUserVoiceForumForParentViewController:self];
}

@end
