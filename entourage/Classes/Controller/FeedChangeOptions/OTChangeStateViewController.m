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

@interface OTChangeStateViewController ()

@property (nonatomic, strong) IBOutlet OTNextStatusButtonBehavior *nextStatusBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleEditBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleSignalEntourageBehavior;

@end

@implementation OTChangeStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeBorderColors];
    [self.toggleEditBehavior initialize];
    [self.toggleEditBehavior toggle:[[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] canEdit] animated:NO];
    [self.toggleSignalEntourageBehavior initialize];
    [self.toggleSignalEntourageBehavior toggle:![[NSUserDefaults standardUserDefaults].currentUser.sid isEqualToNumber:self.feedItem.author.uID] animated:NO];
    [self.nextStatusBehavior configureWith:self.feedItem andProtocol:self.delegate];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    [Flurry logEvent:@"EditEntourageConfirm"];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.editEntourageBehavior doEdit:(OTEntourage *)self.feedItem];
    }];
}

- (IBAction)signalEntourage:(id)sender {
}

#pragma mark - private methods

- (void)changeBorderColors {
    for(UIView *view in self.buttonsWithBorder)
        view.layer.borderColor = [UIColor appOrangeColor].CGColor;
}

@end
