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

@interface OTEntourageDisclaimerViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *switchAccept;

@end

@implementation OTEntourageDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *rejectDisclaimerButton = [self setupCloseModal];
    [rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
}

- (IBAction)showChart:(id)sender {
    [OTLogger logEvent:@"LinkToEthicsChartClick"];
    NSString *url = [[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO] ? PRO_ENTOURAGE_CREATION_CHART : PUBLIC_ENTOURAGE_CREATION_CHART;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)disclaimerAccepted:(id)sender {
    [OTLogger logEvent:@"AcceptEthicsChartClick"];
    if(self.switchAccept.isOn)
        if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasAccepted)])
            [self.disclaimerDelegate disclaimerWasAccepted];
}

- (void)doRejectDisclaimer {
    [OTLogger logEvent:@"CloseEthicsPopupClick"];
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasRejected)])
        [self.disclaimerDelegate disclaimerWasRejected];
}

@end
