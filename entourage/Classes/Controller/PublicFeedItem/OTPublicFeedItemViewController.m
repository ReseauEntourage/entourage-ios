//
//  OTPublicFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicFeedItemViewController.h"
#import "OTSummaryProviderBehavior.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "UIBarButtonItem+factory.h"
#import "OTFeedItemJoinRequestViewController.h"

@interface OTPublicFeedItemViewController () <OTFeedItemJoinRequestDelegate>

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *mapAnnotationProvider;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.summaryProvider configureWith:self.feedItem];
    [self.mapAnnotationProvider configureWith:self.feedItem];
    [self.mapAnnotationProvider addStartPoint];
    [self.mapAnnotationProvider drawData];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    UIBarButtonItem *joinButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self andAction:@selector(doJoin)];
    [self.navigationItem setRightBarButtonItem:joinButton];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"JoinRequestSegue"]) {
        OTFeedItemJoinRequestViewController *controller = (OTFeedItemJoinRequestViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = self.feedItem;
        controller.feedItemJoinRequestDelegate = self;
    }
}

#pragma mark - OTFeedItemJoinRequestDelegate

- (void)dismissFeedItemJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)doJoin {
    [self performSegueWithIdentifier:@"JoinRequestSegue" sender:self];
}

@end
