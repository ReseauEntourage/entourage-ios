//
//  OTEntourageDisclaimerViewController.m
//  entourage
//
//  Created by sergiu.buceac on 06/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEntourageDisclaimerViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAPIConsts.h"

@interface OTEntourageDisclaimerViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *switchAccept;
@property (nonatomic, strong) UIBarButtonItem *rejectDisclaimerButton;

@end

@implementation OTEntourageDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rejectDisclaimerButton = [self setupCloseModal];
    [self.rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
}

- (IBAction)showChart:(id)sender {
    [OTLogger logEvent:@"LinkToEthicsChartClick"];
    NSString *url = IS_PRO_USER ? PRO_ENTOURAGE_CREATION_CHART : PUBLIC_ENTOURAGE_CREATION_CHART;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)disclaimerAccepted:(id)sender {
    [OTLogger logEvent:@"AcceptEthicsChartClick"];
    if (self.switchAccept.isOn) {
        self.rejectDisclaimerButton.enabled = NO;
        [self performSelector:@selector(acceptDisclaimer) withObject:nil afterDelay:0.5];
    }
}

- (void)doRejectDisclaimer {
    [OTLogger logEvent:@"CloseEthicsPopupClick"];
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasRejected)])
        [self.disclaimerDelegate disclaimerWasRejected];
}

- (void)acceptDisclaimer {
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasAccepted)])
        [self.disclaimerDelegate disclaimerWasAccepted];
}

@end
