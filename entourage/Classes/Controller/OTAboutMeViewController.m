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

@interface OTAboutMeViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet OTTapViewBehavior *tapBehavior;

@end

@implementation OTAboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aboutMeMessage.placeholder = @"";
    self.aboutMeMessage.maxLength = 200;
    // Do any additional setup after loading the view.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doSendDescription {
    NSString *aboutMessage = self.aboutMeMessage.textView.text;
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
