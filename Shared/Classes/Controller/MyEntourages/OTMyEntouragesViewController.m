//
//  OTMyEntouragesViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesViewController.h"
#import "OTCollectionSourceBehavior.h"
#import "OTInvitationsCollectionSource.h"
#import "OTToggleVisibleBehavior.h"
#import "OTMyEntouragesDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTInvitationsService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTMyEntouragesOptionsBehavior.h"
#import "OTFeedItemDetailsBehavior.h"
#import "OTManageInvitationBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTAppDelegate.h"
#import "OTUnreadMessagesService.h"
#import "OTConsts.h"
#import "OTFeedItemFactory.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"
#import "OTMyEntouragesFilter.h"
#import "OTUnderlinedButton.h"

@interface OTMyEntouragesViewController ()

@property (nonatomic, strong) IBOutlet OTCollectionSourceBehavior *invitationsDataSource;
@property (nonatomic, strong) IBOutlet OTInvitationsCollectionSource *invitationsCollectionDataSource;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleCollectionView;
@property (nonatomic, strong) IBOutlet OTMyEntouragesDataSource *entouragesDataSource;
@property (nonatomic, strong) IBOutlet OTTableDataSourceBehavior *entouragesTableDataSource;
@property (nonatomic, strong) IBOutlet OTMyEntouragesOptionsBehavior *optionsBehavior;
@property (nonatomic, strong) IBOutlet OTFeedItemDetailsBehavior *feedItemDetailsBehavior;
@property (nonatomic, strong) IBOutlet OTManageInvitationBehavior* manageInvitation;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIView *rightLineView;
@property (nonatomic) BOOL anonymousMode;
@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.anonymousMode = IS_ANONYMOUS_USER;

    self.optionsButton.hidden = YES;
    
    if (!self.anonymousMode) {
        [self.invitationsCollectionDataSource initialize];
        [self.entouragesTableDataSource initialize];
        self.entouragesDataSource.tableView.rowHeight = UITableViewAutomaticDimension;
        self.entouragesDataSource.tableView.estimatedRowHeight = 200;
        self.entouragesDataSource.noDataSubtitle.text = [OTAppAppearance noMessagesDescription];
    } else {
        UIView *anonymousPlaceholder = [[[NSBundle mainBundle]
                                         loadNibNamed:@"MyEntouragesAnonymousPlaceholder"
                                                owner:nil options:nil] firstObject];
        anonymousPlaceholder.frame = self.view.frame;
        [self.view addSubview:anonymousPlaceholder];
    }

    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.optionsBehavior configureWith:self.optionsDelegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupUnreadState:)
                                                 name:kUpdateGroupUnreadStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.anonymousMode) {
        [self loadInvitations];
        [self.entouragesDataSource loadData];
    }
    [OTAppConfiguration updateAppearanceForMainTabBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [OTLogger logEvent:@"Screen17_2MyMessagesView"];
    [super viewDidAppear:animated];
    [self configureNavigationBar];
    if (!self.anonymousMode) {
        [self.entouragesDataSource.tableView reloadRowsAtIndexPaths:[self.entouragesDataSource.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [OTLogger logEvent:@"BackToFeedClick"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.optionsBehavior prepareSegueForOptions:segue]) {
        [OTLogger logEvent:@"PlusOnMessagesPageClick"];
        return;
    }
    if ([self.feedItemDetailsBehavior prepareSegueForDetails:segue]){
        [OTLogger logEvent:@"DiscussionMembersListView"];
        return;
    }
    if ([self.manageInvitation prepareSegueForManage:segue])
        return;
    if ([self.userProfileBehavior prepareSegueForUserProfile:segue]) {
        return;
    }
    
    if ([segue.identifier isEqualToString:@"FiltersSegue"]) {
        [OTLogger logEvent:@"MessagesFilterClick"];
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTFeedItemFiltersViewController *filtersController = (OTFeedItemFiltersViewController *)controller.topViewController;
        filtersController.filterDelegate = self.entouragesDataSource;
    }
}

- (IBAction)changedEntourages:(id)sender {
    [self.entouragesDataSource loadData];
}

#pragma mark - private methods

- (void)updateGroupUnreadState: (NSNotification *) notification {
    BOOL refreshFeed = [notification.object boolForKey:kNotificationUpdateBadgeRefreshFeed defaultValue:YES];
    
    if (refreshFeed == NO)
        return;

    NSNumber *unreadCount = (NSNumber *)[notification.object objectForKey:kNotificationUpdateBadgeCountKey];
    NSNumber *feedId = (NSNumber *)[notification.object objectForKey:kNotificationUpdateBadgeFeedIdKey];
    
    for (int i = 0; i<self.entouragesDataSource.items.count; i++){
        OTFeedItem *item = self.entouragesDataSource.items[i];
        if([item.uid isEqual:feedId]){
            item.unreadMessageCount = unreadCount;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self.entouragesTableDataSource.dataSource.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)willEnterForeground {
    // if view is visible
    // https://stackoverflow.com/a/2777460/1003545
    if (self.isViewLoaded && self.view.window) {
        [self.entouragesDataSource loadData];
    }
}

- (void)loadInvitations {
    [[OTInvitationsService new] getInvitationsWithStatus:INVITATION_PENDING success:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.invitationsDataSource updateItems:items];
        [self.invitationsCollectionDataSource refresh];
    } failure:nil];
}

- (void)configureNavigationBar {
    
    NSString *buttonTitle = OTLocalizedString(@"all_messages_nav_title").uppercaseString;
    UIFont *buttonFont = [UIFont fontWithName:@"SFUIText-Medium" size:17];
    CGFloat buttonWidth = [buttonTitle sizeWithAttributes:@{NSFontAttributeName:buttonFont}].width;
    UIColor *buttonSelectedColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    CGFloat underlineHeight = 3.0f;
    CGFloat marginOffset = 20.0f;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, buttonWidth , self.navigationController.navigationBar.frame.size.height)];

    [leftButton addTarget:self
                    action:@selector(showAllMessages)
          forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:buttonTitle forState: UIControlStateNormal];
    leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    leftButton.titleLabel.font = buttonFont;
    [leftButton setTitleColor:buttonSelectedColor forState:UIControlStateNormal];

    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    CGRect lineFrame = CGRectMake(-marginOffset,
                                    leftButton.frame.size.height - underlineHeight,
                                    leftButton.frame.size.width + 2*marginOffset,
                                    underlineHeight);
    self.leftLineView = [[UIView alloc] initWithFrame:lineFrame];
    self.leftLineView.backgroundColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [leftButton addSubview:self.leftLineView];
    
    buttonTitle = OTLocalizedString(@"unread_messages_nav_title").uppercaseString;
    buttonWidth = [buttonTitle sizeWithAttributes:@{NSFontAttributeName:buttonFont}].width;
    UIButton *rightButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, buttonWidth , self.navigationController.navigationBar.frame.size.height)];
    [rightButton setTitle: buttonTitle forState: UIControlStateNormal];
    rightButton.titleLabel.font = buttonFont;
    [rightButton setTitleColor:buttonSelectedColor forState:UIControlStateNormal];
    rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightButton addTarget:self action:@selector(showUnread) forControlEvents:UIControlEventTouchUpInside];
    
    lineFrame = CGRectMake(-marginOffset,
                           rightButton.frame.size.height - underlineHeight,
                           rightButton.frame.size.width + 2*marginOffset,
                           underlineHeight);
    self.rightLineView = [[UIView alloc] initWithFrame:lineFrame];
    self.rightLineView.backgroundColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [rightButton addSubview:self.rightLineView];
    
    self.rightLineView.hidden = !((OTMyEntouragesFilter *)self.entouragesDataSource.currentFilter).isUnread;
    self.leftLineView.hidden = ((OTMyEntouragesFilter *)self.entouragesDataSource.currentFilter).isUnread;
}

- (void)showAllMessages {
    self.leftLineView.hidden = NO;
    self.rightLineView.hidden = YES;
    if (!self.anonymousMode) {
        ((OTMyEntouragesFilter *)self.entouragesDataSource.currentFilter).isUnread = NO;
        [self.entouragesDataSource loadData];
    }
}

- (void)showUnread {
    self.leftLineView.hidden = YES;
    self.rightLineView.hidden = NO;
    if (!self.anonymousMode) {
        ((OTMyEntouragesFilter *)self.entouragesDataSource.currentFilter).isUnread = YES;
        [self.entouragesDataSource loadData];
    }
}

@end
