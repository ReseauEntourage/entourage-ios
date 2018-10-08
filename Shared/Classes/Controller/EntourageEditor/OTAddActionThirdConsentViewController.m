//
//  OTAddActionThirdConsentViewController.m
//  entourage
//
//  Created by Smart Care on 05/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAddActionThirdConsentViewController.h"
#import "OTAPIConsts.h"
#import "OTHTTPRequestManager.h"
#import "OTSafariService.h"
#import "NSUserDefaults+OT.h"

@interface OTAddActionThirdConsentViewController ()

@end

@implementation OTAddActionThirdConsentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = OTLocalizedString(@"final_question").uppercaseString;
}

- (IBAction)requestModerationAction {
    self.completionBlock(OTAddActionConsentAnswerTypeRequestModeration);
}

- (IBAction)showGuideActtion {
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, CHARTE_LINK_ID, TOKEN];
    NSString *url = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
}

@end
