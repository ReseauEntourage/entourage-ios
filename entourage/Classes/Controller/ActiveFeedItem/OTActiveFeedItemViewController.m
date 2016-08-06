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
#import "OTStatusChangedBehavior.h"
#import "OTTapViewBehavior.h"
#import "OTTourMessage.h"
#import "OTConsts.h"
#import "SVProgressHUD.h"
#import "OTMapViewController.h"

@interface OTActiveFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTSpeechBehavior *speechBehavior;
@property (strong, nonatomic) IBOutlet OTInviteBehavior *inviteBehavior;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (strong, nonatomic) IBOutlet OTTapViewBehavior *titleTapBehavior;
@property (weak, nonatomic) IBOutlet UITextView *txtChat;
@property (weak, nonatomic) IBOutlet UITableView *tblChat;

@end

@implementation OTActiveFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.summaryProvider configureWith:self.feedItem];
    [self.speechBehavior initialize];
    [self.inviteBehavior configureWith:self.feedItem];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.titleTapBehavior initialize];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    [self setupToolbarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.inviteBehavior prepareSegueForInvite:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    if([segue.identifier isEqualToString:@"SegueMap"]) {
        OTMapViewController *controller = (OTMapViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
    }
}

#pragma mark - private methods

-(void)setupToolbarButtons {
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    if(![stateInfo canChangeEditState])
        return;
    UIBarButtonItem *optionsButton = [UIBarButtonItem createWithImageNamed:@"more" withTarget:self.statusChangedBehavior andAction:@selector(startChangeStatus)];
    if([stateInfo canInvite]) {
        UIBarButtonItem *plusButton = [UIBarButtonItem createWithImageNamed:@"userPlus" withTarget:self.inviteBehavior andAction:@selector(startInvite)];
        [self.navigationItem setRightBarButtonItems:@[optionsButton, plusButton]];
    }
    else
        [self.navigationItem setRightBarButtonItems:@[optionsButton]];
}

- (IBAction)sendMessage {
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] send:self.txtChat.text withSuccess:^(OTTourMessage *message) {
        self.txtChat.text = @"";
        [self.speechBehavior updateRecordButton];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (IBAction)showMap {
    [self performSegueWithIdentifier:@"SegueMap" sender:self];
}

@end
