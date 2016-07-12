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

@implementation OTQuitFeedItemViewController

- (IBAction)doQuitFeedItem {
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        self.feedItem.joinStatus = JOIN_NOT_REQUESTED;
        [self.feedItemQuitDelegate didQuitFeedItem];
    }];
}

- (IBAction)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed quit tour view controller");
    }];
}

@end
