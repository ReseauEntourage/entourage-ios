//
//  OTChangeStateViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTChangeStateViewController.h"
#import "OTToggleVisibleBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "OTSignalEntourageBehavior.h"
#import "OTEntourage.h"
#import "OTConfirmCloseViewController.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "OTShareFeedItemBehavior.h"
#import "entourage-Swift.h"
#import "UIColor+Expanded.h"

@interface OTChangeStateViewController ()

@property (nonatomic, strong) IBOutlet OTNextStatusButtonBehavior *nextStatusBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleEditBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleSignalEntourageBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleShareEntourageBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *togglePromoteEntourageBehavior;
@property (nonatomic, strong) IBOutlet OTSignalEntourageBehavior* singalEntourageBehavior;
@property (nonatomic, strong) IBOutlet OTSignalEntourageBehavior* promoteEntourageBehavior;
@property (nonatomic, weak) IBOutlet OTShareFeedItemBehavior *shareItem;
@property (nonatomic, weak) IBOutlet UIButton *shareBtn;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

@end

@implementation OTChangeStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.shareItem configureWith:self.feedItem];
    [self changeBorderColors];
    
    [self.toggleEditBehavior initialize];
    [self.toggleSignalEntourageBehavior initialize];
    [self.toggleShareEntourageBehavior initialize];
    [self.togglePromoteEntourageBehavior initialize];
    
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    BOOL canEdit = [stateInfo canEdit];
    BOOL canCancelJoin = [stateInfo canCancelJoinRequest];
    
    BOOL canReport = [self.feedItem isKindOfClass:[OTEntourage class]] &&
        ![USER_ID isEqualToNumber:self.feedItem.author.uID] &&
        !canCancelJoin;
    
    // EMA-2422
    BOOL canShare = ![self.feedItem.status isEqualToString:ENTOURAGE_STATUS_SUSPENDED];
    
    BOOL canPromote = [currentUser isCoordinator] && [self.feedItem isOuting];
    
    [self.toggleEditBehavior toggle:canEdit animated:NO];
    [self.toggleSignalEntourageBehavior toggle:canReport animated:NO];
    [self.toggleShareEntourageBehavior toggle:canShare animated:NO];
    [self.togglePromoteEntourageBehavior toggle:canPromote animated:NO];
    
    //Hide share / edit is entourage Closed
    BOOL isClosed = [self.feedItem.status isEqualToString:FEEDITEM_STATUS_CLOSED];
    
    if (!isClosed) {
        [self.shareBtn addTarget:self.shareItem
                  action:@selector(sharePublic:)
        forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.toggleEditBehavior toggle:NO animated:NO];
        [self.toggleShareEntourageBehavior toggle:NO animated:NO];
    }
    
    
    [self.nextStatusBehavior configureWith:self.feedItem andProtocol:self.delegate];
    
    [OTAppState hideTabBar:YES];
}

- (void)prepareForClosing {
    if (self.shouldShowTabBarOnClose) {
        [OTAppState hideTabBar:NO];
    }
}

- (IBAction)doQuitter {
    [self prepareForClosing];
    [OTLogger logEvent:@"CloseEntourageConfirm"];
    [SVProgressHUD show];
    [self performSegueWithIdentifier:@"ConfirmCloseSegue" sender:self];
}

- (IBAction)close:(id)sender {
    [self prepareForClosing];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)edit:(id)sender {
    [OTLogger logEvent:Show_Modify_Entourage];
    [self prepareForClosing];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.editEntourageBehavior doEdit:(OTEntourage *)self.feedItem];
    }];
}

- (IBAction)signalEntourage:(id)sender {
  //  [self prepareForClosing];
    
    if ([self.feedItem isKindOfClass:[OTEntourage class]]) {
         UIColor *textColor = [UIColor colorWithHexString:@"ee3e3a"];
           UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Popup"
                                                                bundle:nil];
        
        NSString *titleStr = OTLocalizedString(@"report_action_title");
        NSString *descriptionStr = OTLocalizedString(@"report_action_attributed_title");
        
        if (![self.feedItem isAction]) {
            titleStr = OTLocalizedString(@"report_event_title");
            descriptionStr = OTLocalizedString(@"report_event_attributed_title");
        }
        
        
        OTPopupViewController *popup = [storyboard instantiateInitialViewController];
        NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString: titleStr];
        [firstString addAttribute:NSForegroundColorAttributeName
                                 value:textColor
                                 range:NSMakeRange(0, firstString.length)];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: descriptionStr];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:@"SFUIText-Medium" size: 17]
                                 range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName
                            value:textColor
                            range:NSMakeRange(0, attributedString.length)];
        [firstString appendAttributedString:attributedString];
        
        popup.labelString = firstString;
        popup.textFieldPlaceholder = OTLocalizedString(@"report_entourage_placeholder");
        popup.buttonTitle = OTLocalizedString(@"report_entourage_button");
        popup.isEntourageReport = YES;
        popup.entourageId = ((OTEntourage *)self.feedItem).uid.stringValue;
        
        [self presentViewController:popup
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)promoteEntourage:(id)sender {
    [self prepareForClosing];
    
    if ([self.feedItem isKindOfClass:[OTEntourage class]]) {
        [self.promoteEntourageBehavior sendPromoteEventMailFor:(OTEntourage *)self.feedItem];
    }
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.nextStatusBehavior prepareForSegue:segue sender:sender])
        return;
}

#pragma mark - private methods

- (void)changeBorderColors {
    UIColor *color = ApplicationTheme.shared.backgroundThemeColor;
    for (UIButton *button in self.buttonsWithBorder) {
        button.layer.borderColor = color.CGColor;
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    self.cancelButton.backgroundColor = color;
}

#pragma mark - InvitesourceDelegate
-(void) shareEntourage {
    UIStoryboard *storyboard = [UIStoryboard activeFeedsStoryboard];
    OTShareEntourageViewController *controller = (OTShareEntourageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"OTShareListEntouragesVC"];
    controller.feedItem = self.feedItem;
    
    if (@available(iOS 13.0, *)) {
        [controller setModalInPresentation:YES];
    }
    [self presentViewController:controller animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)share {
    [self.shareItem configureWith:self.feedItem];
    [self.shareItem shareMember:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
