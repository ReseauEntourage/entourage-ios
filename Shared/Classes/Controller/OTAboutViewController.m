//
//  OTAboutViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 24/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAboutViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "OTAboutTableViewCell.h"
#import "OTAboutItem.h"
#import "NSBundle+entourage.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"
#import "OTHTTPRequestManager.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTSafariService.h"

@import MessageUI;

@interface OTAboutViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *logo;

// Data
@property (nonatomic, strong) NSArray *aboutItems;

@end

@implementation OTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self createMenuButton];
    [self setupCloseModal];
    
    self.aboutItems = [OTAboutViewController createAboutItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = OTLocalizedString(@"aboutTitle").uppercaseString;//@"À PROPOS";
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aboutItems count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OTAboutTableViewCellIdentifier];
    OTAboutItem *aboutItem = [self aboutItemAtIndexPath:indexPath];
    if (aboutItem != nil) {
        cell.titleLabel.text = aboutItem.title;
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTAboutItem *item = [self aboutItemAtIndexPath:indexPath];
    NSString *message;
    switch (item.type) {
        case Rate:
            message = @"RatingClick";
            break;
        case Facebook:
            message = @"FacebookPageClick";
            break;
        case Tutorial:
            message = @"OpenTutorialFromMenu";
            break;
        case GeneralConditions:
            message = @"CGUClick";
            break;
        case FAQ:
            message = @"AppFAQClick";
            break;
        case Website:
            message = @"WebsiteVisitClick";
            break;
        case PolitiqueDeConfidenatialite:
            message = @"PolitiqueDeConfidentialiteClick";
            break;
        default:
            break;
    }
    
    if (message) {
        [OTLogger logEvent:message];
    }
    
    if (indexPath.row == [self.aboutItems count]-1) {
        //Email
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:OTLocalizedString(@"about_email_notavailable")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            return nil;
            
        } else {
        
            [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
            MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
            composeVC.mailComposeDelegate = self;
            
            // Configure the fields of the interface.
            [composeVC setToRecipients:@[item.url]];
            [composeVC setSubject:@""];
            [composeVC setMessageBody:@"" isHTML:NO];
            
            [OTAppConfiguration configureMailControllerAppearance:composeVC];
            
            // Present the view controller modally.
            [self presentViewController:composeVC animated:YES completion:nil];
        }
    }
    if (item.type == Tutorial) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [OTAppState loadTutorialScreen];
        }];
    }
    else if (item.identifier) {
        NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, item.identifier, TOKEN];
        NSString *url = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
        [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
    }
    else {
        [OTSafariService launchInAppBrowserWithUrlString:item.url viewController:self.navigationController];
    }
    return nil;
}

#pragma mark - Items handling

+ (NSArray *)createAboutItems
{
    NSMutableArray *aboutItems = [NSMutableArray array];
    
//    OTAboutItem *itemTutorial = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_tutorial")
//                                                   segueIdentifier:@"TutorialSegueIdentifier"];
//    itemTutorial.type = Tutorial;
//    [aboutItems addObject:itemTutorial];

    OTAboutItem *itemSuggestions = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"menu_suggestions")
                                                                identifier:SUGGESTION_LINK_ID];
    itemSuggestions.type = Suggestions;
    [aboutItems addObject:itemSuggestions];
    
    OTAboutItem *itemRate = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_rateus")
                                                           url:ABOUT_RATE_US_URL];
    itemRate.type = Rate;
    [aboutItems addObject:itemRate];

    OTAboutItem *itemFeedback = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"menu_feedback")
                                                                identifier:FEEDBACK_LINK_ID];
    itemFeedback.type = Feedback;
    [aboutItems addObject:itemFeedback];

    OTAboutItem *itemApplicationUsage = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"menu_application_usage")
                                                                identifier:FAQ_LINK_ID];
    itemApplicationUsage.type = FAQ;
    [aboutItems addObject:itemApplicationUsage];
    
    OTAboutItem *itemJobs = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"menu_jobs")
                                                                identifier:JOBS_LINK_ID];
    itemJobs.type = Jobs;
    [aboutItems addObject:itemJobs];
    
    OTAboutItem *itemCGU = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_cgu")
                                                          identifier:TERMS_LINK_ID];
    itemCGU.type = GeneralConditions;
    [aboutItems addObject:itemCGU];
    
    OTAboutItem *confItem = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_politique_conf")
                                                           identifier:PRIVACY_POLICY_LINK_ID];
    confItem.type = PolitiqueDeConfidenatialite;
    [aboutItems addObject:confItem];
    
    OTAboutItem *itemWebsite = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_website")
                                                              url:ABOUT_WEBSITE_URL];
    itemWebsite.type = Website;
    [aboutItems addObject:itemWebsite];
    
    OTAboutItem *itemEmail = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_email")
                                                            url:ABOUT_EMAIL_ADDRESS];
    [aboutItems addObject:itemEmail];
    
    return aboutItems;
}

- (OTAboutItem *) aboutItemAtIndexPath:(NSIndexPath *)indexPath
{
    OTAboutItem *item = nil;
    if (indexPath && indexPath.row < [self.aboutItems count]) {
        item = [self.aboutItems objectAtIndex:indexPath.row];
    }
    return item;
}

#pragma mark - MFMailComposerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
