//
//  OTFeedItemDetailsBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemDetailsBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTActiveFeedItemViewController.h"
#import "OTPublicFeedItemViewController.h"

@interface OTFeedItemDetailsBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTFeedItemDetailsBehavior

- (void)showDetails:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
    if([[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] isPublic])
       [self.owner performSegueWithIdentifier:@"PublicFeedItemDetailsSegue" sender:self];
    else
        [self.owner performSegueWithIdentifier:@"ActiveFeedItemDetailsSegue" sender:self];
}

- (BOOL)prepareSegueForDetails:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"PublicFeedItemDetailsSegue"]) {
        OTPublicFeedItemViewController *controller = (OTPublicFeedItemViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
    }
    else if([segue.identifier isEqualToString:@"ActiveFeedItemDetailsSegue"]) {
        OTActiveFeedItemViewController *controller = (OTActiveFeedItemViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
    }
    else
        return NO;
    return YES;
}

@end
