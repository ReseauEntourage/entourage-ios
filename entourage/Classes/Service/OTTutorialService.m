//
//  OTTutorialService.m
//  entourage
//
//  Created by sergiu buceac on 2/22/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorialService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTDeepLinkService.h"
#import "OTAPIConsts.h"

#define TUTORIAL_DELAY 2

@implementation OTTutorialService

- (void)showTutorial {
    if(IS_PRO_USER)
        return;
    if([NSUserDefaults standardUserDefaults].autoTutorialShown)
        return;
    [NSUserDefaults standardUserDefaults].autoTutorialShown = YES;
    [self performSelector:@selector(displayTutorial) withObject:self afterDelay:TUTORIAL_DELAY];
}

#pragma mark - private methods

- (void)displayTutorial {
    UIViewController *topController = [[OTDeepLinkService new] getTopViewController];
    UIStoryboard *tutorialStoryboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
    UIViewController *tutorialController = [tutorialStoryboard instantiateInitialViewController];
    [topController presentViewController:tutorialController animated:YES completion:nil];
}

@end
