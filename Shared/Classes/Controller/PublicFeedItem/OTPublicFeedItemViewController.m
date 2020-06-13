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
#import "OTToggleVisibleWithConstraintsBehavior.h"
#import "OTShareFeedItemBehavior.h"
#import "OTConsts.h"
#import "OTEntourage.h"
#import "OTBarButtonView.h"
#import "entourage-Swift.h"
#import "NSUserDefaults+OT.h"
#import "UIImage+processing.h"
#import "OTActiveFeedItemViewController.h"
#import "UIStoryboard+entourage.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTStatusBehavior *statusBehavior;
@property (strong, nonatomic) IBOutlet OTJoinBehavior *joinBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTPublicInfoDataSource *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (nonatomic, strong) IBOutlet OTToggleVisibleWithConstraintsBehavior *toggleJoinViewBehavior;
@property (nonatomic, weak) IBOutlet OTShareFeedItemBehavior *shareFeedItem;
@property (nonatomic, weak) IBOutlet UILabel *lblJoin;
@property (nonatomic, weak) IBOutlet UIButton *btnJoin;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionFooterHeight;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.shareFeedItem configureWith:self.feedItem];
    [self.tableDataSource initialize];
    [self.statusBehavior initialize];
    [self.inviteBehavior initialize];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.statusBehavior updateWith:self.feedItem];
    [self.inviteBehavior configureWith:self.feedItem];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatus:) name:kNotificationJoinRequestSent object:nil];
}

- (void)configureTitleView {
    self.navigationItem.titleView = [OTAppAppearance navigationTitleLabelForFeedItem:self.feedItem];
    NSMutableArray *leftButtons = @[].mutableCopy;
    UIBarButtonItem *backItem = [UIBarButtonItem createWithImageNamed:@"backItem"
                                                           withTarget:self.navigationController andAction:@selector(popViewControllerAnimated:) changeTintColor:YES];
    [leftButtons addObject:backItem];
    [OTAppAppearance leftNavigationBarButtonItemForFeedItem:self.feedItem withBarItem:^(UIBarButtonItem *item) {
        [leftButtons addObject:item];
        self.navigationItem.leftBarButtonItems = leftButtons;
    }];
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

- (void)showDiscussionPage {
    OTActiveFeedItemViewController *activeFeedItemViewController = [[UIStoryboard activeFeedsStoryboard] instantiateViewControllerWithIdentifier:@"OTActiveFeedItemViewController"];
    activeFeedItemViewController.feedItem = self.feedItem;
    [self.navigationController pushViewController:activeFeedItemViewController animated:YES];
}

- (IBAction)scrollToMembers:(id)sender {
    [OTLogger logEvent:@"ScrolltoMembersList"];
    
    CGRect frame = [self.dataSource.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [self.dataSource.tableView setContentOffset:CGPointMake(0, frame.origin.y) animated:YES];
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
    [more setFrame:CGRectMake(0, 0, 44, 44)];

    [more setImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
             forState:UIControlStateNormal];
    more.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;

    [more addTarget:self.statusChangedBehavior action:@selector(startChangeStatus) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:more];
    [self.navigationItem setRightBarButtonItem:infoButton];
    
    // https://jira.mytkw.com/browse/EMA-2128
    return;
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

- (IBAction)updateStatusToAccepted {
    self.feedItem.joinStatus = JOIN_ACCEPTED;
    [self.statusBehavior updateWith:self.feedItem];
    [self.toggleJoinViewBehavior toggle:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    [self showDiscussionPage];
}

- (void)updateStatus:(NSNotification*)notification {
    NSString *status = [notification.userInfo valueForKey:kWSStatus];
    if ([status isEqualToString:JOIN_PENDING]) {
        [self updateStatusToPending];
    } else if ([status isEqualToString:JOIN_ACCEPTED]) {
        [self updateStatusToAccepted];
    }
}

- (IBAction)feedItemStateChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
}

- (void)setJoinLabelAndButtonForItem: (OTFeedItem *)feedItem {
    
    self.lblJoin.textColor = [ApplicationTheme shared].backgroundThemeColor;
    self.btnJoin.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.btnJoin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.lblJoin setText: [OTAppAppearance joinEntourageLabelTitleForFeedItem:feedItem]];
    [self.btnJoin setTitle: [OTAppAppearance joinEntourageButtonTitleForFeedItem:feedItem].uppercaseString forState:UIControlStateNormal];
    
    BOOL hideFooter = ![self.feedItem.joinStatus isEqualToString:JOIN_NOT_REQUESTED] ||
        [self.feedItem.status isEqualToString:FEEDITEM_STATUS_CLOSED];
    
    self.toggleJoinViewBehavior.toggledView.hidden = hideFooter;
    self.statusBehavior.statusLineMarker.hidden = hideFooter;
    self.statusBehavior.btnStatus.hidden = hideFooter;
    self.actionFooterHeight.constant = hideFooter ? 0 : 88;
}

@end
