//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuViewController.h"

// Controller
#import "SWRevealViewController.h"
#import "OTLoginViewController.h"

#import "NSUserDefaults+OT.h"

// Model
#import "OTMenuItem.h"
#import "OTUser.h"

// View
#import "OTMenuTableViewCell.h"
#import "SVProgressHUD.h"

// Utils
#import "NSUserDefaults+OT.h"

/* MenuItem identifiers */
NSString *const OTMenuViewControllerSegueMenuMapIdentifier = @"segueMenuIdentifierForMap";
NSString *const OTMenuViewControllerSegueMenuGuideIdentifier = @"segueMenuIdentifierForGuide";
NSString *const OTMenuViewControllerSegueMenuProfileIdentifier = @"segueMenuIdentifierForProfile";
NSString *const OTMenuViewControllerSegueMenuDisconnectIdentifier = @"segueMenuDisconnectIdentifier";

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

/**************************************************************************************************/
#pragma mark - Getters and Setters

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.menuItems = [OTMenuViewController createMenuItems];
	self.controllersDictionary = [NSMutableDictionary dictionary];
	[self configureControllersDictionary];
    
    self.title = @"MON COMPTE";
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OTMenuTableViewCellIdentifier];
	OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];

	cell.itemLabel.text = [menuItem.title uppercaseStringWithLocale:[NSLocale currentLocale]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.row == self.menuItems.count - 1) {
		[[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		OTLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"OTStartupNavigationViewControllerIdentifier"];
		[self presentViewController:loginViewController animated:YES completion:nil];
	}
	else {
		OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
		[self openControllerWithSegueIdentifier:menuItem.segueIdentifier];

		[Flurry logEvent:@"Open_Screen_From_Menu" withParameters:@{ @"screen" : menuItem.segueIdentifier }];
	}
}

/**************************************************************************************************/
#pragma mark - Actions

/**
 * Method which opens the controller according to segueIdentifier.
 * This method has a particuler implementation.
 * - if the controller is not instanciated, we load it by the segue in Main.Storyboard
 * - if the controller is instanciated and isn't the current frontViewController, we push the new controller
 * - if the controller is instanciated and is the current frontViewController, we do only a revealToggle in order to avoid the effect of disappearance and  appearance
 *
 * @param segueIdentifier
 * The identifier of a segue
 */
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
    if (![self.controllersDictionary objectForKey:segue.identifier] && [segue.identifier isEqualToString:@"OTUserProfile"]) {
        [self.controllersDictionary setObject:segue.destinationViewController forKey:segue.identifier];
    }
}

/**************************************************************************************************/
#pragma mark - Private methods

/**
 * Method which configure controllersDictionary with the first controller displayed by Main.storyboard.
 * According to the storyboard, this first controller is the Map
 * This method should be called in viewDidLoad
 *
 * @see OTMenuViewController - viewDidLoad
 */
- (void)configureControllersDictionary {
	UIViewController *frontViewController = self.revealViewController.frontViewController;

	if (frontViewController) {
		[self.controllersDictionary setObject:frontViewController
		                               forKey:OTMenuViewControllerSegueMenuMapIdentifier];
	}
}

/**
 * Method which creates all MenuItems in expected order for Menu
 *
 * @return NSArray<OTMenuItem>
 * All expected MenuItems
 */
+ (NSArray *)createMenuItems {
	NSMutableArray *menuItems = [NSMutableArray array];

	// Map
	OTMenuItem *itemMap = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_map_title", @"")
	                                        segueIdentifier:OTMenuViewControllerSegueMenuMapIdentifier];

	[menuItems addObject:itemMap];

    // Guide
    OTMenuItem *itemGuide = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_guide_title", @"")
                                              segueIdentifier:OTMenuViewControllerSegueMenuGuideIdentifier];
    
    [menuItems addObject:itemGuide];
    
    // Profile
    OTMenuItem *itemProfile = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_profile_title", @"")
                                                segueIdentifier:OTMenuViewControllerSegueMenuProfileIdentifier];
    [menuItems addObject:itemProfile];

	// Disconnect
	OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
	                                               segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
	[menuItems addObject:itemDisconnect];

	// Version
    /*
	NSString *buildVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary]
	                          objectForKey:@"CFBundleVersion"];

	NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

	version = [NSString stringWithFormat:@"%@ (%@)", version, buildVersion];
	OTMenuItem *itemVersion = [[OTMenuItem alloc] initWithTitle:version segueIdentifier:nil];
	[menuItems addObject:itemVersion];
     */

	return menuItems;
}

/**
 * Method which returns MenuItem according an indexpath
 *
 * @param indexPath
 * The indexPath to find the corresponding MenuItem in MenuItems
 *
 * @return OTMenuItem
 * The MenuItem according the indexpath
 */
- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuItem *menuItem = nil;

	if (indexPath && (indexPath.row < self.menuItems.count)) {
		menuItem = [self.menuItems objectAtIndex:indexPath.row];
	}

	return menuItem;
}

@end
