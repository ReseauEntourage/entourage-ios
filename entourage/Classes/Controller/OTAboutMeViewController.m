//
//  OTAboutMeViewController.m
//  entourage
//
//  Created by veronica.gliga on 26/10/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAboutMeViewController.h"
#import "OTTapViewBehavior.h"
#import "SVProgressHUD.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAuthService.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "OTCloseKeyboardOnTapBehavior.h"

@interface OTAboutMeViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet OTTapViewBehavior *tapBehavior;
@property (nonatomic, weak) IBOutlet OTCloseKeyboardOnTapBehavior *closeKeyboardBehavior;

@end

@implementation OTAboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    self.closeKeyboardBehavior.inputViews = [NSArray arrayWithObjects:self.aboutMeTextWithCount.textView, nil];
    self.aboutMeTextWithCount.placeholder = @"";
    self.aboutMeTextWithCount.maxLength = 200;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.aboutMeTextWithCount.textView becomeFirstResponder];
    self.aboutMeTextWithCount.textView.text = self.aboutMeMessage;
    if(self.aboutMeMessage && ![self.aboutMeMessage isEqualToString:@""])
        [self.aboutMeTextWithCount updateAfterSpeech];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doSendDescription {
    NSString *aboutMessage = self.aboutMeTextWithCount.textView.text;
    if (!aboutMessage)
        aboutMessage = @"";
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.about = aboutMessage;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(setNewAboutMe:)]) {
        [self.delegate setNewAboutMe:aboutMessage];
    }
    [self close:self];
}

@end
