//
//  OTChangeStateViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
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
    BOOL canShare = ![self.feedItem.joinStatus isEqualToString:JOIN_ACCEPTED];
    BOOL canPromote = [currentUser isCoordinator] && [self.feedItem isOuting];
    
    [self.toggleEditBehavior toggle:canEdit animated:NO];
    [self.toggleSignalEntourageBehavior toggle:canReport animated:NO];
    [self.toggleShareEntourageBehavior toggle:canShare animated:NO];
    [self.togglePromoteEntourageBehavior toggle:canPromote animated:NO];
    
    [self.shareBtn addTarget:self.shareItem
                      action:@selector(sharePublic:)
            forControlEvents:UIControlEventTouchUpInside];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    [OTLogger logEvent:@"EditEntourageConfirm"];
    [self prepareForClosing];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.editEntourageBehavior doEdit:(OTEntourage *)self.feedItem];
    }];
}

- (IBAction)signalEntourage:(id)sender {
    [self prepareForClosing];
    
    if ([self.feedItem isKindOfClass:[OTEntourage class]]) {
        [self.singalEntourageBehavior sendMailFor:(OTEntourage *)self.feedItem];
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

@end
