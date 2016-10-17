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
#import "OTFeedItemJoinMessageController.h"
#import "OTStatusBehavior.h"
#import "OTJoinBehavior.h"
#import "SVProgressHUD.h"
#import "OTUserProfileBehavior.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *mapAnnotationProvider;
@property (strong, nonatomic) IBOutlet OTStatusBehavior *statusBehavior;
@property (strong, nonatomic) IBOutlet OTJoinBehavior *joinBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet UITextView *txtDescription;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txtDescription.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appGreyishBrownColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    [self.summaryProvider configureWith:self.feedItem];
    [self.statusBehavior initialize];
    [self.statusBehavior updateWith:self.feedItem];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    FeedItemState state = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    if(FeedItemStateJoinNotRequested == state) {
        UIBarButtonItem *joinButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self andAction:@selector(joinFeedItem:)];
        [self.navigationItem setRightBarButtonItem:joinButton];
    }
}

- (void)viewDidLayoutSubviews {
    [self.mapAnnotationProvider configureWith:self.feedItem];
    [self.mapAnnotationProvider addStartPoint];
    [self.mapAnnotationProvider drawData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showUserProfile:(id)sender {
    [Flurry logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
}

#pragma mark - private methods

- (IBAction)joinFeedItem:(id)sender {
    [Flurry logEvent:@"AskJoinFromPublicPage"];
    [self.joinBehavior join:self.feedItem];
}

- (IBAction)updateStatusToPending {
    self.feedItem.joinStatus = JOIN_PENDING;
    [self.statusBehavior updateWith:self.feedItem];
    [self.navigationItem setRightBarButtonItem:nil];
}

@end
