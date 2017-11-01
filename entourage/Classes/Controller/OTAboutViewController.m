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
#import "OTAboutTableViewCell.h"
#import "OTAboutItem.h"
#import "NSBundle+entourage.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"
@import MessageUI;

@interface OTAboutViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *aboutItems;

@end

@implementation OTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"aboutTitle").uppercaseString;//@"À PROPOS";
    //[self createMenuButton];
    [self setupCloseModal];
    
    self.aboutItems = [OTAboutViewController createAboutItems];
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
        if (indexPath.row == 0) {
            if([[ConfigurationManager shared].environment isEqualToString:@"staging"])
                cell.extraLabel.text = [NSString stringWithFormat:@"v%@",[NSBundle fullCurrentVersion]];
            else
                cell.extraLabel.text = [NSString stringWithFormat:@"v%@",[NSBundle currentVersion]];
        }
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
        case GeneralConditions:
            message = @"CGUClick";
            break;
        case Website:
            message = @"WebsiteVisitClick";
            break;
        default:
            break;
    }
    [OTLogger logEvent:message];
    if (indexPath.row == [self.aboutItems count]-1) {
        //Email
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:OTLocalizedString(@"about_email_notavailable")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {}];
            
            [alert addAction:defaultAction];
            return nil;
        }
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[item.url]];
        [composeVC setSubject:@""];
        [composeVC setMessageBody:@"" isHTML:NO];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.url]];
    }
    return nil;
}

#pragma mark - Items handling

+ (NSArray *)createAboutItems
{
    NSMutableArray *aboutItems = [NSMutableArray array];
    
    OTAboutItem *itemRate = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_rateus")
                                                           url:ABOUT_RATE_US_URL];
    itemRate.type = Rate;
    [aboutItems addObject:itemRate];
    
    OTAboutItem *itemFacebook = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_facebook")
                                                               url:ABOUT_FACEBOOK_URL];
    itemFacebook.type = Facebook;
    [aboutItems addObject:itemFacebook];
    
    OTAboutItem *itemCGU = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_cgu")
                                                          url:ABOUT_CGU_URL];
    itemCGU.type = GeneralConditions;
    [aboutItems addObject:itemCGU];
    
    OTAboutItem *itemApplicationUsage = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"menu_application_usage")
                                                                       url:MENU_BLOG_APPLICATION_USAGE_URL];
    [aboutItems addObject:itemApplicationUsage];
    
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
