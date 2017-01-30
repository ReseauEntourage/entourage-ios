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
    self.title = OTLocalizedString(@"myProfile").capitalizedString;
    [self createBackFrontMenuButton];
    [self.modifyLabel underline];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePictureUpdated:) name:@kNotificationProfilePictureUpdated object:nil];
}

- (void)viewDidLayoutSubviews {
    [self.profileButton setupAsProfilePictureFromUrl:self.currentUser.avatarURL withPlaceholder:@"user"];
    self.imgAssociation.hidden = self.currentUser.partner == nil;
    [self.imgAssociation setupFromUrl:self.currentUser.partner.smallLogoUrl withPlaceholder:@"user"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"OpenMenu"];
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [self.currentUser displayName];
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == 0) ? 30.f : 1.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? self.menuItems.count - 1 : 1 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = (indexPath.section == 0) ?   OTMenuTableViewCellIdentifier :
                                                    OTMenuLogoutTableViewCellIdentifier;
    OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
    if (menuItem.iconName != nil)
        cell.itemIcon.image = [UIImage imageNamed:menuItem.iconName];
    cell.itemLabel.text = menuItem.title;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
        [Flurry logEvent:@"LogOut"];
        [OTOngoingTourService sharedInstance].isOngoing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailureNotification object:self];
	}
	else {
		OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
        if(menuItem.segueIdentifier)
            [self openControllerWithSegueIdentifier:menuItem.segueIdentifier];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItem.url]];
	}
    [[tableView cellForRowAtIndexPath:indexPath]setSelected:NO];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)showProfile {
    [Flurry logEvent:@"TapMyProfilePhoto"];
    [self performSegueWithIdentifier:@"segueMenuIdentifierForProfile" sender:self];
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
        [Flurry logEvent:@"AboutClick"];
    else if([segue.identifier isEqualToString:OTMenuViewControllerSegueMenuDisconnectIdentifier]) {
        [Flurry logEvent:@"LogOut"];
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
    OTMenuItem *itemBlog = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_blog") iconName: @"blog" url:MENU_BLOG_URL];
    [menuItems addObject:itemBlog];
    NSString *chartUrl = [self.currentUser.type isEqualToString:USER_TYPE_PRO] ? PRO_MENU_CHART_URL : PUBLIC_MENU_CHART_URL;
    OTMenuItem *itemChart = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_chart") iconName: @"chart" url:chartUrl];
    [menuItems addObject:itemChart];
    OTMenuItem *itemAbout = [[OTMenuItem alloc] initWithTitle:OTLocalizedString(@"menu_about") iconName: @"about" segueIdentifier:OTMenuViewControllerSegueMenuAboutIdentifier];
    [menuItems addObject:itemAbout];
    OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"") iconName: nil segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
    [menuItems addObject:itemDisconnect];
	return menuItems;
}

- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuItem *menuItem = nil;
	if (indexPath && (indexPath.row < self.menuItems.count))
		menuItem = [self.menuItems objectAtIndex:indexPath.row];
    if (indexPath.section == 1)
        menuItem = [self.menuItems lastObject];
	return menuItem;
}

- (void)profilePictureUpdated:(NSNotification *)notification {
    self.currentUser.avatarURL = [[[NSUserDefaults standardUserDefaults] currentUser] avatarURL];
    [self.profileButton setupAsProfilePictureFromUrl:self.currentUser.avatarURL withPlaceholder:@"user"];
}

@end
