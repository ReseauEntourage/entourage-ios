//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTMenuViewController.h"
#import "OTConsts.h"
#import "SWRevealViewController.h"
#import "OTLoginViewController.h"
#import "UIViewController+menu.h"
#import "OTSettingsViewController.h"
#import "OTUserViewController.h"
#import "NSUserDefaults+OT.h"
#import "OTMenuItem.h"
#import "OTUser.h"
#import "OTMenuTableViewCell.h"
#import "SVProgressHUD.h"
#import "UIButton+AFNetworking.h"
#import "UIButton+entourage.h"
#import "NSUserDefaults+OT.h"
#import "NSBundle+entourage.h"
#import "OTOngoingTourService.h"
#import "UILabel+entourage.h"
#import "OTTapViewBehavior.h"
#import "UIImageView+entourage.h"
#import "OTAPIConsts.h"
#import "OTSolidarityGuideFiltersViewController.h"


#define HEADER_CELL_INDEX 7
#define LOG_OUT_CELL_INDEX 8
#define SOLIDARITY_GUIDE_INDEX 3

@import MessageUI;

/* MenuItem identifiers */
NSString *const OTMenuViewControllerSegueMenuMapIdentifier = @"segueMenuIdentifierForMap";
NSString *const OTMenuViewControllerSegueMenuGuideIdentifier = @"segueMenuIdentifierForGuide";
NSString *const OTMenuViewControllerSegueMenuProfileIdentifier = @"segueMenuIdentifierForProfile";
NSString *const OTMenuViewControllerSegueMenuSettingsIdentifier = @"segueMenuIdentifierForSettings";
NSString *const OTMenuViewControllerSegueMenuDisconnectIdentifier = @"segueMenuDisconnectIdentifier";
NSString *const OTMenuViewControllerSegueMenuAboutIdentifier = @"segueMenuIdentifierForAbout";

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

// Data
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad {
	[super viewDidLoad];

    [self.tapNameBehavior initialize];
    [self.tapModifyBehavior initialize];
    [self.tapAssociation initialize];
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
	self.menuItems = [self createMenuItems];
	self.controllersDictionary = [NSMutableDictionary dictionary];
	[self configureControllersDictionary];
    self.title = OTLocalizedString(@"myProfile");
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    [self createBackFrontMenuButton];
    [self.modifyLabel underline];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = self.headerView;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    
    [OTLogger logEvent:@"OpenMenu"];
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [self.currentUser displayName];
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID;
    if(indexPath.row == 2)
        cellID = OTMenuMakeDonationTableViewCellIdentifier;
    else if (indexPath.row == HEADER_CELL_INDEX)
        cellID = @"HeaderViewCell";
    else if (indexPath.row == LOG_OUT_CELL_INDEX)
        cellID = OTMenuLogoutTableViewCellIdentifier;
    else
        cellID = OTMenuTableViewCellIdentifier;
    
        
    OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
    if (menuItem.iconName != nil)
        cell.itemIcon.image = [UIImage imageNamed:menuItem.iconName];
    if (menuItem.title != nil)
        cell.itemLabel.text = menuItem.title;
    else
        cell.contentView.backgroundColor = [UIColor colorWithRed:239 green:239 blue:244 alpha:1];
    if (indexPath.row == HEADER_CELL_INDEX || indexPath.row == LOG_OUT_CELL_INDEX)
        cell.separatorInset = UIEdgeInsetsZero;
    if (indexPath.row == 2)
        cell.contentView.backgroundColor = [UIColor colorWithRed:242 green:101 blue:33 alpha:1];
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
    else if (indexPath.row == SOLIDARITY_GUIDE_INDEX) {
        [OTLogger logEvent:@"SolidarityGuideFrom07Menu"];
        [self.revealViewController revealToggle:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSolidarityGuideNotification object:self];
    }
    else {
		OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
        if(menuItem.segueIdentifier)
            [self openControllerWithSegueIdentifier:menuItem.segueIdentifier];
        else {
            if([menuItem.title isEqualToString:OTLocalizedString(@"menu_entourage_actions")])
                [OTLogger logEvent:@"WhatActionsClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_application_usage")])
                [OTLogger logEvent:@"AppFAQClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_scb")])
                [OTLogger logEvent:@"SimpleCommeBonjourClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_chart")])
                [OTLogger logEvent:@"ViewEthicsChartClick"];
            else if ([menuItem.title isEqualToString:OTLocalizedString(@"menu_atd_partner")])
                [OTLogger logEvent:@"ATDPartnershipView"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItem.url]];
        }
	}
    [[tableView cellForRowAtIndexPath:indexPath]setSelected:NO];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)showProfile {
    [OTLogger logEvent:@"TapMyProfilePhoto"];
    [self performSegueWithIdentifier:OTMenuViewControllerSegueMenuProfileIdentifier sender:self];
}

- (IBAction)editProfile {
    [self performSegueWithIdentifier:@"EditProfileSegue" sender:self];
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
    if([segue.identifier isEqualToString:OTMenuViewControllerSegueMenuAboutIdentifier])
        [OTLogger logEvent:@"AboutClick"];
    else if([segue.identifier isEqualToString:OTMenuViewControllerSegueMenuDisconnectIdentifier]) {
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
                                                         url:MENU_SCB_URL];
    [menuItems addObject:itemBlog];
    
    OTMenuItem *itemEntourageActions = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_entourage_actions")
                                                                iconName:@"goal"
                                                                     url:MENU_BLOG_ENTOURAGE_ACTIONS_URL];
    [menuItems addObject:itemEntourageActions];
    
    
    //add 3rd new one
    OTMenuItem *itemDon = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_make_donation")
                                                   iconName:@"heartNofillWhite"
                                                        url:@""];
    [menuItems addObject:itemDon];
    
    
    OTMenuItem *itemSolidarityGuide = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_solidarity_guide")
                                                               iconName:@"mapPin"];
    [menuItems addObject:itemSolidarityGuide];
    
    OTMenuItem *itemAtd = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_atd_partner")
                                                   iconName:@"atdLogo"
                                                        url:MENU_ATD_PARTNERSHIP];
    [menuItems addObject:itemAtd];
    
    NSString *chartUrl = IS_PRO_USER ? PRO_MENU_CHART_URL : PUBLIC_MENU_CHART_URL;
    OTMenuItem *itemChart = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_chart")
                                                     iconName: @"chart"
                                                          url:chartUrl];
    [menuItems addObject:itemChart];
    
    OTMenuItem *itemAbout = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_about")
                                                     iconName: @"about"
                                              segueIdentifier:OTMenuViewControllerSegueMenuAboutIdentifier];
    [menuItems addObject:itemAbout];
    
    OTMenuItem *itemNil = [[OTMenuItem alloc] initWithTitle:nil iconName: nil ];
    [menuItems addObject:itemNil];
    
    OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
                                                          iconName: nil
                                                   segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
    [menuItems addObject:itemDisconnect];
	return menuItems;
}

- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuItem *menuItem = nil;
	if (indexPath && (indexPath.row < self.menuItems.count))
		menuItem = [self.menuItems objectAtIndex:indexPath.row];
//    if (indexPath.section == 1)
//        menuItem = [self.menuItems lastObject];
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

@end
