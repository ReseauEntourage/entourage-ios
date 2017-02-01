//
//  OTMapViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapViewController.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTStatusChangedBehavior.h"
#import "OTSummaryProviderBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTInviteBehavior.h"
#import "UIBarButtonItem+factory.h"
#import "OTMembersDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTEditEntourageBehavior.h"
#import "UIImageView+entourage.h"

@interface OTMapViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (nonatomic, weak) IBOutlet OTSummaryProviderBehavior *summaryProviderBehavior;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (nonatomic, weak) IBOutlet OTInviteBehavior *inviteBehavior;
@property (nonatomic, weak) IBOutlet OTMembersDataSource *membersDataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *membersTableSource;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior *editEntourageBehavior;

@end

@implementation OTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgAssociation.hidden = self.feedItem.author.partner == nil;
    [self.imgAssociation setupFromUrl:self.feedItem.author.partner.smallLogoUrl withPlaceholder:@"user"];
    [self.summaryProviderBehavior configureWith:self.feedItem];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.inviteBehavior configureWith:self.feedItem];
    [self.membersTableSource initialize];
    self.membersDataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.membersDataSource.tableView.estimatedRowHeight = 1000;

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    [self setupToolbarButtons];
    [self.membersDataSource loadDataFor:self.feedItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showProfile {
    [Flurry logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.inviteBehavior prepareSegueForInvite:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    if([self.editEntourageBehavior prepareSegue:segue])
        return;
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    if(![stateInfo canChangeEditState])
        return;
    NSMutableArray *rightButtons = [NSMutableArray new];
    UIBarButtonItem *optionsButton = [UIBarButtonItem createWithImageNamed:@"more" withTarget:self.statusChangedBehavior andAction:@selector(startChangeStatus)];
    [rightButtons addObject:optionsButton];
    if([stateInfo canInvite]) {
        UIBarButtonItem *plusButton = [UIBarButtonItem createWithImageNamed:@"userPlus" withTarget:self.inviteBehavior andAction:@selector(startInvite)];
        [rightButtons addObject:plusButton];
    }
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

@end
