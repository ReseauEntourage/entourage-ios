//
//  OTChangeStateViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChangeStateViewController.h"
#import "OTToggleVisibleBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "OTSignalEntourageBehavior.h"
#import "OTEntourage.h"
#import "OTConfirmCloseViewController.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"


@interface OTChangeStateViewController ()

@property (nonatomic, strong) IBOutlet OTNextStatusButtonBehavior *nextStatusBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleEditBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleSignalEntourageBehavior;
@property (nonatomic, strong) IBOutlet OTSignalEntourageBehavior* singalEntourageBehavior;

@end

@implementation OTChangeStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeBorderColors];
    [self.toggleEditBehavior initialize];
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    BOOL canCancelJoin = [stateInfo canCancelJoinRequest];
    [self.toggleEditBehavior toggle:[stateInfo canEdit] animated:NO];
    [self.toggleSignalEntourageBehavior initialize];
    [self.toggleSignalEntourageBehavior toggle:[self.feedItem isKindOfClass:[OTEntourage class]] && ![USER_ID isEqualToNumber:self.feedItem.author.uID] && !canCancelJoin animated:NO];
    [self.nextStatusBehavior configureWith:self.feedItem andProtocol:self.delegate];
}

- (IBAction)doQuitter {
    [OTLogger logEvent:@"CloseEntourageConfirm"];
    [SVProgressHUD show];
    [self performSegueWithIdentifier:@"ConfirmCloseSegue" sender:self];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    [OTLogger logEvent:@"EditEntourageConfirm"];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.editEntourageBehavior doEdit:(OTEntourage *)self.feedItem];
    }];
}

- (IBAction)signalEntourage:(id)sender {
    if([self.feedItem isKindOfClass:[OTEntourage class]])
        [self.singalEntourageBehavior sendMailFor:(OTEntourage *)self.feedItem];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.nextStatusBehavior prepareForSegue:segue sender:sender])
        return;
}

#pragma mark - private methods

- (void)changeBorderColors {
    for(UIView *view in self.buttonsWithBorder)
        view.layer.borderColor = [UIColor appOrangeColor].CGColor;
}

@end
