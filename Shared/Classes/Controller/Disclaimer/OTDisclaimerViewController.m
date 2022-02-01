//
//  OTDisclaimerViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 09/06/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTDisclaimerViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"

@interface OTDisclaimerViewController ()

@property (nonatomic, weak) IBOutlet UITextView *txtMessage;

@end

@implementation OTDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txtMessage.attributedText = self.disclaimerText;
    self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName:[ApplicationTheme shared].backgroundThemeColor};
    
    //resolution to issue http://www.openradar.me/24435091
    self.txtMessage.scrollEnabled = NO;
    self.txtMessage.scrollEnabled = YES;
    
    UIBarButtonItem *rejectDisclaimerButton = [self setupCloseModal];
    [rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
    
    [self setupCloseModalWithoutTintWithTint:UIColor.appOrangeColor];
}

- (IBAction)doAcceptDisclaimer {
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasAccepted)])
        [self.disclaimerDelegate disclaimerWasAccepted];
}

- (void)doRejectDisclaimer {
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasRejected)])
        [self.disclaimerDelegate disclaimerWasRejected];
}

@end
