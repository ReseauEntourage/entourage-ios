//
//  OTDisclaimerViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 09/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDisclaimerViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+menu.h"

@interface OTDisclaimerViewController ()

@property (nonatomic, weak) IBOutlet UITextView *txtMessage;

@end

@implementation OTDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txtMessage.text = self.disclaimerText;
    UIBarButtonItem *rejectDisclaimerButton =  [self setupCloseModal];
    [rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
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
