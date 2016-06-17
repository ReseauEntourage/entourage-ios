//
//  OTQuitTourViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTQuitFeedItemViewController.h"
#import "OTTourService.h"
#import "OTFeedItemFactory.h"
#import "OTStateTransitionDelegate.h"

@implementation OTQuitFeedItemViewController

- (IBAction)doQuitFeedItem {
    id<OTStateTransitionDelegate> stateTransitionHandler = [[OTFeedItemFactory createFor:self.feedItem] getStateTransition];
    
    [stateTransitionHandler quitWithSuccess:^() {
        self.feedItem.joinStatus = @"not_requested";
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.feedItemQuitDelegate didQuitFeedItem];
    }];
}

- (IBAction)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed quit tour view controller");
    }];
}

@end
