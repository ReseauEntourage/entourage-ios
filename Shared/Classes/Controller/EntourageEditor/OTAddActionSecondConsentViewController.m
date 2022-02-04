//
//  OTAddActionSecondConsentViewController.m
//  entourage
//
//  Created by Smart Care on 05/10/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTAddActionSecondConsentViewController.h"
#import "OTAddActionThirdConsentViewController.h"
#import "UIStoryboard+entourage.h"
#import "UIColor+entourage.h"
#import "OTAPIConsts.h"
#import "OTHTTPRequestManager.h"
#import "NSUserDefaults+OT.h"
#import "OTSafariService.h"

@interface OTAddActionSecondConsentViewController ()
@property (nonatomic, weak) IBOutlet UILabel *termsLabel;
@end

@implementation OTAddActionSecondConsentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = OTLocalizedString(@"final_question").uppercaseString;
}

- (IBAction)acceptAction {
    self.completionBlock(OTAddActionConsentAnswerTypeAcceptActionDistribution);
}

- (IBAction)rejectAction {
    UIStoryboard *storyboard = [UIStoryboard entourageEditorStoryboard];
    OTAddActionThirdConsentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTAddActionThirdConsentViewController"];
    vc.completionBlock = self.completionBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showGuideActtion {
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, CHARTE_LINK_ID, TOKEN];
    NSString *url = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
}

@end
