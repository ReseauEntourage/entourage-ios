//
//  OTSocialViewController.m
//  entourage
//
//  Created by veronica.gliga on 19/12/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSocialViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "OTAboutTableViewCell.h"
#import "OTAboutItem.h"
#import "NSBundle+entourage.h"
#import "UIColor+entourage.h"
#import "OTHTTPRequestManager.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTDeepLinkService.h"
#import "OTSafariService.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@interface OTSocialViewController () <UITableViewDelegate, UITableViewDataSource>

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *aboutItems;

@end

@implementation OTSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"socialTitle").capitalizedString;
    [self setupCloseModal];
    self.aboutItems = [OTSocialViewController createItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        
        if (indexPath.row == 0) {
            if ([[OTAppConfiguration sharedInstance].environmentConfiguration runsOnProduction]) {
                cell.extraLabel.text = [NSString stringWithFormat:@"v%@", [NSBundle currentVersion]];
                
            } else {
                cell.extraLabel.text = [NSString stringWithFormat:@"v%@",[NSBundle fullCurrentVersion]];
            }
        }
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTAboutItem *item = [self aboutItemAtIndexPath:indexPath];
    if (indexPath.row == 3 || indexPath.row == 4) {
        NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, item.identifier, TOKEN];
        NSString *url = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
        [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.url]];
    }
    return nil;
}

#pragma mark - Items handling

+ (NSArray *)createItems
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
    
    OTAboutItem *itemTwitter = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_twitter")
                                                              url:ABOUT_TWITTER_URL];
    itemTwitter.type = Twitter;
    [aboutItems addObject:itemTwitter];
    
    OTAboutItem *itemSuggestions = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_suggestions")
                                                           identifier:SUGGESTION_LINK_ID];
    itemSuggestions.type = Suggestions;
    [aboutItems addObject:itemSuggestions];
    
    OTAboutItem *itemJoin = [[OTAboutItem alloc] initWithTitle:OTLocalizedString(@"about_join")
                                                    identifier:JOIN_LINK_ID];
    itemJoin.type = Join;
    [aboutItems addObject:itemJoin];
    
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

@end
