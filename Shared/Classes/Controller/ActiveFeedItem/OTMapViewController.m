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
#import "OTConsts.h"
#import "OTBarButtonView.h"
#import "entourage-Swift.h"
#import "NSUserDefaults+OT.h"
#import "UIImage+processing.h"

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
    [self.imgAssociation setupFromUrl:self.feedItem.author.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    [self.summaryProviderBehavior configureWith:self.feedItem];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.inviteBehavior configureWith:self.feedItem];
    [self.membersTableSource initialize];
    self.membersDataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.membersDataSource.tableView.estimatedRowHeight = 1000;

    [self configureTitleView];
    [self setupToolbarButtons];
    [self.membersDataSource loadDataFor:self.feedItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen14_2PublicPageViewAsMemberOrCreator"];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;}

- (void)configureTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    id iconName = [[[OTFeedItemFactory createFor:self.feedItem] getUI] categoryIconSource];
    id titleString = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle];
    UIButton *iconButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    iconButton.backgroundColor = UIColor.whiteColor;
    iconButton.layer.cornerRadius = 18;
    [iconButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    iconButton.userInteractionEnabled = NO;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 40)];
    title.text = titleString;
    title.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [titleView addSubview:iconButton];
    [titleView addSubview:title];
    self.navigationItem.titleView = titleView;
}

- (IBAction)showProfile {
    [OTLogger logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.inviteBehavior prepareSegueForInvite:segue])
        return;
    if ([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if ([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    if ([self.editEntourageBehavior prepareSegue:segue])
        return;
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    if(![stateInfo canChangeEditState])
        return;
    
    NSMutableArray *rightButtons = [NSMutableArray new];
    UIButton *options = [UIButton buttonWithType:UIButtonTypeCustom];
    [options setImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:UIControlStateNormal];
    options.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [options addTarget:self.statusChangedBehavior
                action:@selector(startChangeStatus)
      forControlEvents:UIControlEventTouchUpInside];
    [options setFrame:CGRectMake(0, 0, 30, 30)];
    
    OTBarButtonView *optionsBarBtnView = [[OTBarButtonView alloc] initWithFrame:options.frame];
    [optionsBarBtnView setPosition:BarButtonViewPositionRight];
    [optionsBarBtnView addSubview:options];
    
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithCustomView:optionsBarBtnView];
    [rightButtons addObject:optionsButton];
    [self setRightBarButtonView:rightButtons];
}

- (void)setRightBarButtonView:(NSMutableArray *)views
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 11)
    {
        [self.navigationItem setRightBarButtonItems:views];
    }
    else
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        [space setWidth:-13];
        
        NSArray *items = @[space];
        
        [self.navigationItem setRightBarButtonItems:[items arrayByAddingObjectsFromArray:views]];
    }
}

@end
