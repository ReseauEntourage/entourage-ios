//
//  OTPublicFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicFeedItemViewController.h"
#import "OTSummaryProviderBehavior.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "UIBarButtonItem+factory.h"
#import "OTStatusBehavior.h"
#import "OTJoinBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTUserProfileBehavior.h"
#import "OTPublicInfoDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTStatusChangedBehavior.h"
#import "OTToggleVisibleWithConstraintsBehavior.h"
#import "OTShareFeedItemBehavior.h"
#import "OTConsts.h"
#import "OTEntourage.h"
#import "OTBarButtonView.h"
#import "entourage-Swift.h"
#import "NSUserDefaults+OT.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTStatusBehavior *statusBehavior;
@property (strong, nonatomic) IBOutlet OTJoinBehavior *joinBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTPublicInfoDataSource *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleWithConstraintsBehavior *toggleJoinViewBehavior;
@property (nonatomic, weak) IBOutlet OTShareFeedItemBehavior *shareFeedItem;
@property (nonatomic, weak) IBOutlet UILabel *lblJoin;
@property (nonatomic, weak) IBOutlet UIButton *btnJoin;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.shareFeedItem configureWith:self.feedItem];
    [self.tableDataSource initialize];
    [self.statusBehavior initialize];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.statusBehavior updateWith:self.feedItem];
    [self.toggleJoinViewBehavior toggle:self.statusBehavior.isJoinPossible];
    self.dataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.dataSource.tableView.estimatedRowHeight = 1000;

    [self configureTitleView];
    [self setupToolbarButtons];
    [self setJoinLabelAndButtonForItem:self.feedItem];
    [self.dataSource loadDataFor:self.feedItem];
}

- (void)configureTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    BOOL isPrivateCircle = [NSUserDefaults standardUserDefaults].currentUser.privateCircles.count > 0;
    id iconName = isPrivateCircle ? @"private-circle" : [[[OTFeedItemFactory createFor:self.feedItem] getUI] categoryIconSource];
    id titleString = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle];
    UIButton *iconButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    iconButton.backgroundColor = UIColor.whiteColor;
    iconButton.layer.cornerRadius = 20;
    [iconButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    iconButton.userInteractionEnabled = NO;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 40)];
    title.text = titleString;
    title.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [titleView addSubview:iconButton];
    [titleView addSubview:title];
    self.navigationItem.titleView = titleView;
}

- (void)viewDidLayoutSubviews {
    [self.tableDataSource refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
}

- (IBAction)showUserProfile:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    NSMutableArray *rightButtons = [NSMutableArray new];
    
    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    [more setFrame:CGRectMake(0, 0, 30, 30)];
    
    if([self.feedItem isKindOfClass:[OTEntourage class]]) {
        [more setImage:[UIImage imageNamed:@"more"]
              forState:UIControlStateNormal];
        [more addTarget:self.statusChangedBehavior
                 action:@selector(startChangeStatus)
         forControlEvents:UIControlEventTouchUpInside];
        OTBarButtonView *moreBarBtnView = [[OTBarButtonView alloc] initWithFrame:more.frame];
        [moreBarBtnView setPosition:BarButtonViewPositionRight];
        [moreBarBtnView addSubview:more];
        
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:moreBarBtnView];
        [rightButtons addObject:moreButton];
        
        UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
        [share setImage:[UIImage imageNamed:@"share_native"]
               forState:UIControlStateNormal];
        [share addTarget:self.shareFeedItem
                  action:@selector(sharePublic:)
        forControlEvents:UIControlEventTouchUpInside];
        [share setFrame:CGRectMake(0, 0, 30, 30)];
        
        OTBarButtonView *shareBarBtnView = [[OTBarButtonView alloc] initWithFrame:share.frame];
        [shareBarBtnView setPosition:BarButtonViewPositionRight];
        [shareBarBtnView addSubview:share];
        
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithCustomView:shareBarBtnView];
        
        [rightButtons addObject:shareButton];
    }
    else {
        [more setImage:[UIImage imageNamed:@"info"]
              forState:UIControlStateNormal];
        [more addTarget:self.statusChangedBehavior
                 action:@selector(startChangeStatus)
       forControlEvents:UIControlEventTouchUpInside];
        
        OTBarButtonView *infoBarBtnView = [[OTBarButtonView alloc] initWithFrame:more.frame];
        [infoBarBtnView setPosition:BarButtonViewPositionRight];
        [infoBarBtnView addSubview:more];
        
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoBarBtnView];
        [rightButtons addObject:infoButton];
    }
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
        items = [items arrayByAddingObjectsFromArray:views];
        
        [self.navigationItem setRightBarButtonItems:items];
    }
}

- (IBAction)joinFeedItem:(id)sender {
    [OTLogger logEvent:@"AskJoinFromPublicPage"];
    if(![self.joinBehavior join:self.feedItem])
       [self.statusChangedBehavior startChangeStatus];
}

- (IBAction)updateStatusToPending {
    self.feedItem.joinStatus = JOIN_PENDING;
    [self.statusBehavior updateWith:self.feedItem];
    [self.toggleJoinViewBehavior toggle:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
}

- (IBAction)feedItemStateChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
}

- (void)setJoinLabelAndButtonForItem: (OTFeedItem *)feedItem {
    if([feedItem isKindOfClass:[OTEntourage class]]) {
        [self.lblJoin setText: OTLocalizedString(@"join_entourage_lbl")];
        [self.btnJoin setTitle: OTLocalizedString(@"join_entourage_btn") forState:UIControlStateNormal];
    }
    else {
        [self.lblJoin setText: OTLocalizedString(@"join_tour_lbl")];
        [self.btnJoin setTitle: OTLocalizedString(@"join_tour_btn") forState:UIControlStateNormal];
    }
}

@end
