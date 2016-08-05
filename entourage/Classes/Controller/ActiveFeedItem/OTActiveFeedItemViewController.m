//
//  OTActiveFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTActiveFeedItemViewController.h"
#import "OTFeedItemFactory.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"
#import "OTStateInfoDelegate.h"
#import "OTSummaryProviderBehavior.h"
#import "OTSpeechBehavior.h"
#import "OTInviteBehavior.h"

@interface OTActiveFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTSpeechBehavior *speechBehavior;
@property (strong, nonatomic) IBOutlet OTInviteBehavior *inviteBehavior;
@property (weak, nonatomic) IBOutlet UITableView *tblChat;

@end

@implementation OTActiveFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.summaryProvider configureWith:self.feedItem];
    [self.speechBehavior initialize];
    [self.inviteBehavior configureWith:self.feedItem];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    [self setupToolbarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.inviteBehavior prepareSegueForInvite:segue];
}

#pragma mark - private methods

-(void)setupToolbarButtons {
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    if(![stateInfo canChangeEditState])
        return;
    UIBarButtonItem *optionsButton = [UIBarButtonItem createWithImageNamed:@"more" withTarget:self andAction:@selector(showOptions)];
    if([stateInfo canInvite]) {
        UIBarButtonItem *plusButton = [UIBarButtonItem createWithImageNamed:@"userPlus" withTarget:self.inviteBehavior andAction:@selector(startInvite)];
        [self.navigationItem setRightBarButtonItems:@[optionsButton, plusButton]];
    }
    else
        [self.navigationItem setRightBarButtonItems:@[optionsButton]];
}

- (void)showOptions {
    
}

@end
