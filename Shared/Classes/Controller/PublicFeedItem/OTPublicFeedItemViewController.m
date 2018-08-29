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
#import "UIImage+processing.h"

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
    
    [self.toggleJoinViewBehavior.toggledView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.toggleJoinViewBehavior.toggledView.layer setShadowOpacity:0.5];
    [self.toggleJoinViewBehavior.toggledView.layer setShadowRadius:4.0];
    [self.toggleJoinViewBehavior.toggledView.layer setShadowOffset:CGSizeMake(0.0, 1.0)];

    [self configureTitleView];
    [self setupToolbarButtons];
    [self setJoinLabelAndButtonForItem:self.feedItem];
    [self.dataSource loadDataFor:self.feedItem];
}

- (void)configureTitleView {
    self.navigationItem.titleView = [OTAppAppearance navigationTitleLabelForFeedItem:self.feedItem];
    NSMutableArray *leftButtons = @[].mutableCopy;
    UIBarButtonItem *backItem = [UIBarButtonItem createWithImageNamed:@"backItem"
                                                           withTarget:self.navigationController andAction:@selector(popViewControllerAnimated:) changeTintColor:YES];
    [leftButtons addObject:backItem];
    [leftButtons addObject:[OTAppAppearance leftNavigationBarButtonItemForFeedItem:self.feedItem]];
    self.navigationItem.leftBarButtonItems = leftButtons;
}

- (void)viewDidLayoutSubviews {
    [self.tableDataSource refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppState hideTabBar:YES];
}

- (IBAction)showUserProfile:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.joinBehavior prepareSegueForMessage:segue]) {
        return;
    }
    
    if ([self.userProfileBehavior prepareSegueForUserProfile:segue]) {
        return;
    }
    
    if ([self.statusChangedBehavior prepareSegueForNextStatus:segue]) {
        return;
    }
}

#pragma mark - private methods

- (void)setupToolbarButtons {

    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    [more setFrame:CGRectMake(0, 0, 30, 30)];
    [more setBackgroundImage:[[UIImage imageNamed:@"info"] resizeTo:CGSizeMake(25, 25)]
                    forState:UIControlStateNormal];
    [more addTarget:self.statusChangedBehavior action:@selector(startChangeStatus) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:more];
    [self.navigationItem setRightBarButtonItem:infoButton];
    
    // https://jira.mytkw.com/browse/EMA-2128
    return;
    
    if ([self.feedItem isKindOfClass:[OTEntourage class]]) {
        
        NSMutableArray *rightButtons = [NSMutableArray new];
        UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
        [more setFrame:CGRectMake(0, 0, 30, 30)];
        
        [more setImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        more.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
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
        [self setRightBarButtonView:rightButtons];
    }
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
    
    if (![self.joinBehavior join:self.feedItem]) {
       [self.statusChangedBehavior startChangeStatus];
    }
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
    
    self.lblJoin.textColor = [ApplicationTheme shared].backgroundThemeColor;
    self.btnJoin.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.btnJoin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.lblJoin setText: [OTAppAppearance joinEntourageLabelTitleForFeedItem:feedItem]];
    [self.btnJoin setTitle: [OTAppAppearance joinEntourageButtonTitleForFeedItem:feedItem] forState:UIControlStateNormal];
}

@end
