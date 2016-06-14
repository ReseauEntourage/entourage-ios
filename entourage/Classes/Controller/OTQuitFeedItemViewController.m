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
#import "OTStateFactoryDelegate.h"

@implementation OTQuitFeedItemViewController

- (IBAction)doQuitFeedItem {
    id<OTStateFactoryDelegate> stateHandler = [[OTFeedItemFactory createFor:self.feedItem] getStateFactory];
    
    [stateHandler quitWithSuccess:^() {
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
