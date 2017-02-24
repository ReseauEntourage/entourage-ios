//
//  OTManageInvitationViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTManageInvitationViewController.h"
#import "UIColor+entourage.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "OTSummaryProviderBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTInvitationChangedBehavior.h"
#import "OTBadgeNumberService.h"

@interface OTManageInvitationViewController ()

@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *annotationProvider;
@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProviderBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTInvitationChangedBehavior *invitationChangedBehavior;
@property (strong, nonatomic) IBOutlet UIButton *btnIgnore;
@property (strong, nonatomic) IBOutlet UITextView *txtDescription;

@end

@implementation OTManageInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtDescription.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appGreyishBrownColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    [self.summaryProviderBehavior configureWith:self.feedItem];
    [self.annotationProvider configureWith:self.feedItem];
    [self.annotationProvider addStartPoint];
    [self.annotationProvider drawData];
    self.invitationChangedBehavior.pendingInvitationChangedDelegate = self.pendingInvitationsChangedDelegate;
    
    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    self.btnIgnore.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnIgnore.layer.borderWidth = 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[OTBadgeNumberService sharedInstance] readItem:self.feedItem.uid];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showProfile {
    [OTLogger logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

- (IBAction)accept {
    [self.invitationChangedBehavior accept:self.invitation];
}

- (IBAction)ignore {
    [self.invitationChangedBehavior ignore:self.invitation];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
}

@end
