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
#import "SVProgressHUD.h"
#import "OTConsts.h"

@implementation OTQuitFeedItemViewController

- (IBAction)doQuitFeedItem {
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [self.feedItemQuitDelegate didQuitFeedItem:self.feedItem];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (IBAction)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed quit tour view controller");
    }];
}

@end
