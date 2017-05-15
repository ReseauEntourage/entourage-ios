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
#import "OTInviteBehavior.h"
#import "OTStatusChangedBehavior.h"
#import "OTTapViewBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTEditEntourageBehavior.h"
#import "OTFeedItemMessage.h"
#import "OTConsts.h"
#import "SVProgressHUD.h"
#import "OTMapViewController.h"
#import "OTMessagingService.h"
#import "IQKeyboardManager.h"
#import "OTBottomScrollBehavior.h"
#import "OTUnreadMessagesService.h"
#import "OTShareFeedItemBehavior.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTEditEncounterBehavior.h"
#import "OTMessageTableCellProviderBehavior.h"

@interface OTActiveFeedItemViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTInviteBehavior *inviteBehavior;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (strong, nonatomic) IBOutlet OTTapViewBehavior *titleTapBehavior;
@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior *editEntourageBehavior;
@property (nonatomic, weak) IBOutlet OTEditEncounterBehavior *editEncounterBehavior;
@property (nonatomic, weak) IBOutlet OTMessageTableCellProviderBehavior *cellProvider;
@property (weak, nonatomic) IBOutlet UITextView *txtChat;
@property (weak, nonatomic) IBOutlet UITableView *tblChat;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (nonatomic, strong) IBOutlet OTBottomScrollBehavior *scrollBottomBehavior;
@property (nonatomic, weak) IBOutlet OTShareFeedItemBehavior *shareBehavior;

@end

@implementation OTActiveFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUIForClosedItem];
    [self.shareBehavior configureWith:self.feedItem];
    [self.scrollBottomBehavior initialize];
    [self.summaryProvider configureWith:self.feedItem];
    [self.inviteBehavior configureWith:self.feedItem];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.titleTapBehavior initialize];
    [self.tableDataSource initialize];
    self.dataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.dataSource.tableView.estimatedRowHeight = 1000;
    self.cellProvider.feedItem = self.feedItem;

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    [self setupToolbarButtons];
    [self reloadMessages];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[OTActiveFeedItemViewController class]];
    
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:self.feedItem.type andId:self.feedItem.uid] getMessaging] setMessagesAsRead:^{
        [SVProgressHUD dismiss];
        [[OTUnreadMessagesService new] removeUnreadMessages:self.feedItem.uid];
    } orFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (void)reloadMessages {
    [[OTMessagingService new] readFor:self.feedItem onDataSource:self.dataSource];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.inviteBehavior prepareSegueForInvite:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([self.editEntourageBehavior prepareSegue:segue])
        return;
    if([self.editEncounterBehavior prepareSegue:segue])
        return;
    if([segue.identifier isEqualToString:@"SegueMap"]) {
        OTMapViewController *controller = (OTMapViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
    }
}

#pragma mark - private methods

- (void)setUpUIForClosedItem {
    BOOL isClosed = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] isClosed];
    if(isClosed)
        self.view.backgroundColor = self.tblChat.backgroundColor = CLOSED_ITEM_BACKGROUND_COLOR;
    self.txtChat.hidden = self.btnSend.hidden = isClosed;
    self.txtChat.delegate = self;
}

- (void)setupToolbarButtons {
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
    NSString *message = [self.txtChat.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(message.length == 0)
        return;
    [OTLogger logEvent:@"AddContentToMessage"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] send:message withSuccess:^(OTFeedItemMessage *message) {
        [SVProgressHUD dismiss];
        self.txtChat.text = @"";
        [[OTMessagingService new] readFor:self.feedItem onDataSource:self.dataSource];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (IBAction)showMap {
    [OTLogger logEvent:@"EntouragePublicPageViewFromMessages"];
    [self performSegueWithIdentifier:@"SegueMap" sender:self];
}

- (IBAction)scrollToBottomWhileEditing {
    if(self.dataSource.items.count > 0)
        [self.dataSource.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.items.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)encounterChanged {
    [self reloadMessages];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [OTLogger logEvent:@"WriteMessage"];
}

@end
