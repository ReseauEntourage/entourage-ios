//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>

#import "OTAppDelegate.h"
#import "OTMenuViewController.h"
#import "OTConsts.h"
#import "OTLoginViewController.h"
#import "UIViewController+menu.h"
#import "OTSettingsViewController.h"
#import "OTUserViewController.h"
#import "NSUserDefaults+OT.h"
#import "OTMenuItem.h"
#import "OTUser.h"
#import "OTMenuTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIButton+entourage.h"
#import "NSBundle+entourage.h"
#import "OTOngoingTourService.h"
#import "UILabel+entourage.h"
#import "OTTapViewBehavior.h"
#import "UIImageView+entourage.h"
#import "OTAPIConsts.h"
#import "OTSolidarityGuideFiltersViewController.h"
#import "OTHTTPRequestManager.h"
#import "OTDeepLinkService.h"
#import "OTAboutViewController.h"
#import "OTSafariService.h"
#import "OTAppConfiguration.h"
#import "OTAuthService.h"
#import "entourage-Swift.h"

#define SOLIDARITY_GUIDE_INDEX 2
#define DONATION_CELL_INDEX 4
#define HEADER_CELL_INDEX 8
#define LOG_OUT_CELL_INDEX 9

typedef NS_ENUM(NSInteger, OTEntourageMenuIndexType) {
    OTEntourageMenuIndexTypeBlog = 0,
    OTEntourageMenuIndexTypeActions,
    OTEntourageMenuIndexTypeSolidarityGuide,
    OTEntourageMenuIndexTypeJoin,
    OTEntourageMenuIndexTypeDonation,
    OTEntourageMenuIndexTypeAtd,
    OTEntourageMenuIndexTypeChart,
    OTEntourageMenuIndexTypeAbout,
    OTEntourageMenuIndexTypeNil,
    OTEntourageMenuIndexTypeLogout
};

@import MessageUI;

/* MenuItem identifiers */
NSString *const OTMenuViewControllerSegueMenuMapIdentifier = @"segueMenuIdentifierForMap";
NSString *const OTMenuViewControllerSegueMenuGuideIdentifier = @"segueMenuIdentifierForGuide";
NSString *const OTMenuViewControllerSegueMenuProfileIdentifier = @"segueMenuIdentifierForProfile";
NSString *const OTMenuViewControllerSegueMenuSettingsIdentifier = @"segueMenuIdentifierForSettings";
NSString *const OTMenuViewControllerSegueMenuDisconnectIdentifier = @"segueMenuDisconnectIdentifier";
NSString *const OTMenuViewControllerSegueMenuAboutIdentifier = @"segueMenuIdentifierForAbout";
NSString *const OTMenuViewControllerSegueMenuSocialIdentifier = @"segueMenuIdentifierForSocial";

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

/**************************************************************************************************/
#pragma mark - Getters and Setters

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet OTTapViewBehavior *tapNameBehavior;
@property (weak, nonatomic) IBOutlet OTTapViewBehavior *tapModifyBehavior;
@property (weak, nonatomic) IBOutlet OTTapViewBehavior *tapAssociation;
@property (weak, nonatomic) IBOutlet UIImageView *imgAssociation;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet OTIdentificationOverlayView *identificationOverlayView;

// Data
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;
@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic) BOOL isUserConnected;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad {
	[super viewDidLoad];
    
     self.navigationItem.title = OTLocalizedString(@"myProfile");

    [self.tapNameBehavior initialize];
    [self.tapModifyBehavior initialize];
    [self.tapAssociation initialize];
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.isUserConnected = self.currentUser == nil ? FALSE : TRUE;
	self.controllersDictionary = [NSMutableDictionary dictionary];
	[self configureControllersDictionary];
   
    [self createBackFrontMenuButton];
    if (!self.isUserConnected) {
        self.modifyLabel.text = @"login / sign up";
    }
    [self.modifyLabel underline];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = self.headerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePictureUpdated:) name:@kNotificationProfilePictureUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSupportedPartner:) name:@kNotificationSupportedPartnerUpdated object:nil];
}

- (void)viewDidLayoutSubviews {
    [self.profileButton setupAsProfilePictureFromUrl:self.currentUser.avatarURL withPlaceholder:@"user"];
    [self updateSupportedPartner:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [OTLogger logEvent:@"OpenMenu"];
    if (self.isUserConnected) {
        [self loadUser];
        self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        self.nameLabel.text = [self.currentUser displayName];
    } else {
        // show login/sign up button under picture
        self.nameLabel.text = @"";
        self.modifyLabel.text = @"login / sign up";
        self.menuItems = [self createMenuItems];
    }
    [OTAppConfiguration updateAppearanceForMainTabBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)loadUser {
    [SVProgressHUD show];
    [[OTAuthService new] getDetailsForUser:self.currentUser.sid success:^(OTUser *user) {
        [SVProgressHUD dismiss];
        self.currentUser = user;
        self.menuItems = [self createMenuItems];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_profile_error")];
        self.menuItems = [self createMenuItems];
        [self.tableView reloadData];
    }];
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID;
    if (indexPath.row == DONATION_CELL_INDEX)
        cellID = OTMenuMakeDonationTableViewCellIdentifier;
    else if (indexPath.row == HEADER_CELL_INDEX)
        cellID = @"HeaderViewCell";
    else if (indexPath.row == LOG_OUT_CELL_INDEX)
        cellID = OTMenuLogoutTableViewCellIdentifier;
    else
        cellID = OTMenuTableViewCellIdentifier;
    
    OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
    if (menuItem.iconName != nil) {
        cell.itemIcon.image = [UIImage imageNamed:menuItem.iconName];
        cell.itemIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (menuItem.title != nil) {
        cell.itemLabel.text = menuItem.title;
    }
    else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:239 green:239 blue:244 alpha:1];
    }
    
    if ((indexPath.row == HEADER_CELL_INDEX ||
         indexPath.row == HEADER_CELL_INDEX - 1) ||
        (indexPath.row == LOG_OUT_CELL_INDEX ||
         indexPath.row == DONATION_CELL_INDEX ||
        indexPath.row == DONATION_CELL_INDEX - 1))
        cell.separatorInset = UIEdgeInsetsZero;
    
    if (indexPath.row == DONATION_CELL_INDEX) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:242
                                                           green:101
                                                            blue:33
                                                           alpha:1];
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.row == LOG_OUT_CELL_INDEX) {
        [OTLogger logEvent:@"LogOut"];
        [OTOngoingTourService sharedInstance].isOngoing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailureNotification object:self];
	}
    else if(indexPath.row == SOLIDARITY_GUIDE_INDEX) {
        [OTLogger logEvent:@"SolidarityGuideFrom07Menu"];
        [self.revealViewController revealToggle:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSolidarityGuideNotification object:self];
//        NSArray *deepLinks = @[
//                               @"https://www.entourage.social/deeplink/guide",
//                               @"https://www.entourage.social/entourages/e0nEjytD9mU8",
//                               @"https://www.entourage.social/deeplink/badge",
//                               @"https://www.entourage.social/deeplink/feed",
//                               @"https://www.entourage.social/deeplink/webview?url=https://www.google.ro",
//                               @"https://www.entourage.social/deeplink/entourage/e0nEjytD9mU8"
//                               ];
//        NSTimeInterval delta = 10;
//        NSTimeInterval delay = 5;
//        for (NSString *deepLink in deepLinks) {
//            [self performSelector:@selector(testDeepLink:) withObject:deepLink afterDelay:delay];
//            delay += delta;
//        }
    }
    else {
		OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
        if(menuItem.segueIdentifier)
            [self openControllerWithSegueIdentifier:menuItem.segueIdentifier];
        else {
            if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_entourage_actions")])
                [OTLogger logEvent:@"WhatActionsClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_scb")])
                [OTLogger logEvent:@"SimpleCommeBonjourClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_chart")])
                [OTLogger logEvent:@"ViewEthicsChartClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_atd_partner")])
                [OTLogger logEvent:@"ATDPartnershipView"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_join")])
                [OTLogger logEvent:@"AmbassadorProgramClick"];
            
            NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, menuItem.identifier, TOKEN];
            NSString *url = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
            
            if  ( ([menuItem.title isEqualToString:OTLocalizedString(@"menu_scb")]) ||
                [menuItem.title isEqualToString:OTLocalizedString(@"menu_entourage_actions")] ) {
                [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
            }
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_chart")]) {
                NSString *userId = self.currentUser.sid.stringValue;
                NSString *url = [NSString stringWithFormat:CHARTE_LINK_FORMAT_PUBLIC, userId];
                if ([self.currentUser isPro]) {
                    url = [NSString stringWithFormat:CHARTE_LINK_FORMAT_PRO, userId];
                }
                [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
            }
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_join")]) {
                [OTSafariService launchInAppBrowserWithUrlString:JOIN_URL viewController:self.navigationController];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
	}
    [[tableView cellForRowAtIndexPath:indexPath]setSelected:NO];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)showProfile {
    [OTLogger logEvent:@"TapMyProfilePhoto"];
    if (self.isUserConnected) {
        [self performSegueWithIdentifier:OTMenuViewControllerSegueMenuProfileIdentifier sender:self];
    }
}

- (IBAction)editProfile {
    if (self.isUserConnected) {
        [self performSegueWithIdentifier:@"EditProfileSegue" sender:self];
    } else {
        self.identificationOverlayView.alpha = 1;
    }
}

- (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier {
	UIViewController *nextViewController = [self.controllersDictionary objectForKey:segueIdentifier];
	if (nextViewController) {
		SWRevealViewController *revealViewController = self.revealViewController;
		if (nextViewController != self.revealViewController.frontViewController) {
			[revealViewController pushFrontViewController:nextViewController animated:YES];
		}
		else {
			[revealViewController revealToggle:self];
		}
	}
	else {
		[self performSegueWithIdentifier:segueIdentifier sender:self];
	}
}

/**************************************************************************************************/
#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:OTMenuViewControllerSegueMenuAboutIdentifier]) {
        [OTLogger logEvent:@"AboutClick"];
    } else if([segue.identifier isEqualToString:OTMenuViewControllerSegueMenuDisconnectIdentifier]) {
        [OTLogger logEvent:@"LogOut"];
        [OTOngoingTourService sharedInstance].isOngoing = NO;
    }
    if (![self.controllersDictionary objectForKey:segue.identifier] && [segue.identifier isEqualToString:@"segueMenuIdentifierForProfile"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.user = [[NSUserDefaults standardUserDefaults] currentUser];
    }
}


#pragma mark - Private methods

- (void)configureControllersDictionary {
	UIViewController *frontViewController = self.revealViewController.frontViewController;
	if (frontViewController)
		[self.controllersDictionary setObject:frontViewController forKey:OTMenuViewControllerSegueMenuMapIdentifier];
}

- (NSArray *)createMenuItems {
	NSMutableArray *menuItems = [NSMutableArray array];
    OTMenuItem *itemBlog = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_scb")
                                                    iconName: @"blog"
                                                  identifier:SCB_LINK_ID];
    [menuItems addObject:itemBlog];
    
    OTMenuItem *itemEntourageActions = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_entourage_actions")
                                                                iconName:@"goal"
                                                              identifier:GOAL_LINK_ID];
    [menuItems addObject:itemEntourageActions];
    
    
   
    OTMenuItem *itemSolidarityGuide = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_solidarity_guide")
                                                               iconName:@"mapPin"];
    [menuItems addObject:itemSolidarityGuide];
    
    OTMenuItem *itemJoin = [[OTMenuItem alloc]    initWithTitle:OTLocalizedString(@"menu_join")
                                                               iconName:@"menu_ba"];
    itemJoin.tag = OTEntourageMenuIndexTypeJoin;
    [menuItems addObject:itemJoin];
    
    OTMenuItem *itemDon = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_make_donation")
                                                   iconName:@"heartNofillWhite"
                                                 identifier:DONATE_LINK_ID];
    [menuItems addObject:itemDon];
    
    OTMenuItem *itemAtd = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_atd_partner")
                                                   iconName:@"broadcast"
                                                 segueIdentifier:OTMenuViewControllerSegueMenuSocialIdentifier];
    [menuItems addObject:itemAtd];
    
    NSString *chartTitle;
    if (self.isUserConnected) {
        chartTitle = [self.currentUser hasSignedEthicsChart] ? OTLocalizedString(@"menu_read_chart") : OTLocalizedString(@"menu_sign_chart");
    } else {
        chartTitle =  OTLocalizedString(@"menu_read_chart");
    }
    OTMenuItem *itemChart = [[OTMenuItem alloc] initWithTitle:chartTitle
                                                     iconName: @"chart"
                                                   identifier:CHARTE_LINK_ID];
    [menuItems addObject:itemChart];
    
    OTMenuItem *itemAbout = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_about")
                                                     iconName: @"about"
                                              segueIdentifier:OTMenuViewControllerSegueMenuAboutIdentifier];
    [menuItems addObject:itemAbout];
    
    if (self.isUserConnected) {
        OTMenuItem *itemNil = [[OTMenuItem alloc] initWithTitle:nil iconName: nil ];
        [menuItems addObject:itemNil];
        
        OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
                                                              iconName: nil
                                                       segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
        [menuItems addObject:itemDisconnect];

    }
    
	return menuItems;
}

- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuItem *menuItem = nil;
	if (indexPath && (indexPath.row < self.menuItems.count))
		menuItem = [self.menuItems objectAtIndex:indexPath.row];
	return menuItem;
}

- (void)profilePictureUpdated:(NSNotification *)notification {
    self.currentUser.avatarURL = [[[NSUserDefaults standardUserDefaults] currentUser] avatarURL];
    [self.profileButton setupAsProfilePictureFromUrl:self.currentUser.avatarURL withPlaceholder:@"user"];
}

- (void)updateSupportedPartner:(NSNotification *)notification {
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    self.imgAssociation.hidden = self.currentUser.partner == nil;
    [self.imgAssociation setupFromUrl:self.currentUser.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
}

- (void)testDeepLink:(NSString *)deepLink {
    [[OTDeepLinkService new] handleUniversalLink:[NSURL URLWithString:deepLink]];
}

@end
