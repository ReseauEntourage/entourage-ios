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

@import MessageUI;

#import "NSBundle+entourage.h"
#import "UIColor+entourage.h"

@interface OTAboutViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *aboutItems;

@end

@implementation OTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"À PROPOS";
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
            //Add the version number on first item
            cell.extraLabel.text = [NSString stringWithFormat:@"v%@",[NSBundle currentVersion]];
        }
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTAboutItem *item = [self aboutItemAtIndexPath:indexPath];
    if (indexPath.row == [self.aboutItems count]-1) {
        //Email
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"about_email_notavailable", @"")
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
    
    OTAboutItem *itemRate = [[OTAboutItem alloc] initWithTitle:NSLocalizedString(@"about_rateus", @"")
                                                           url:ABOUT_RATE_US_URL];
    [aboutItems addObject:itemRate];
    
    OTAboutItem *itemFacebook = [[OTAboutItem alloc] initWithTitle:NSLocalizedString(@"about_facebook", @"")
                                                               url:ABOUT_FACEBOOK_URL];
    [aboutItems addObject:itemFacebook];
    
    OTAboutItem *itemCGU = [[OTAboutItem alloc] initWithTitle:NSLocalizedString(@"about_cgu", @"")
                                                          url:ABOUT_CGU_URL];
    [aboutItems addObject:itemCGU];
    
    OTAboutItem *itemWebsite = [[OTAboutItem alloc] initWithTitle:NSLocalizedString(@"about_website", @"")
                                                              url:ABOUT_WEBSITE_URL];
    [aboutItems addObject:itemWebsite];
    
    OTAboutItem *itemEmail = [[OTAboutItem alloc] initWithTitle:NSLocalizedString(@"about_email", @"")
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
