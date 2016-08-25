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

@interface OTManageInvitationViewController ()

@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *annotationProvider;
@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProviderBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet UIButton *btnIgnore;

@end

@implementation OTManageInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.summaryProviderBehavior configureWith:self.feedItem];
    [self.annotationProvider configureWith:self.feedItem];
    [self.annotationProvider addStartPoint];
    [self.annotationProvider drawData];
    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    self.btnIgnore.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnIgnore.layer.borderWidth = 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showProfile {
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
}

@end
