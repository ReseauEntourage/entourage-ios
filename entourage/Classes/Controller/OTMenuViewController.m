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

// Model
#import "OTMenuItem.h"

// View
#import "OTMenuTableViewCell.h"

/* MenuItem identifiers */
NSString *const OTMenuViewControllerSegueMenuMapIdentifier = @"segueMenuMapIdentifier";
NSString *const OTMenuViewControllerSegueMenuMyMeetingsIdentifier = @"segueMenuMyMeetingsIdentifier";
NSString *const OTMenuViewControllerSegueMenuPracticalInformationIdentifier = @"segueMenuPracticalInformationIdentifier";
NSString *const OTMenuViewControllerSegueMenuForumIdentifier = @"segueMenuForumIdentifier";
NSString *const OTMenuViewControllerSegueMenuMembersIdentifier = @"segueMenuMembersIdentifier";
NSString *const OTMenuViewControllerSegueMenuMyProfileIdentifier = @"segueMenuMyProfileIdentifier";
NSString *const OTMenuViewControllerSegueMenuMyNotificationsIdentifier = @"segueMenuMyNotificationsIdentifier";
NSString *const OTMenuViewControllerSegueMenuHelpIdentifier = @"segueMenuHelpIdentifier";
NSString *const OTMenuViewControllerSegueMenuYourOpinionIdentifier = @"segueMenuYourOpinionIdentifier";
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = [OTMenuViewController createMenuItems];
    self.controllersDictionary = [NSMutableDictionary dictionary];
    [self configureControllersDictionary];
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OTMenuTableViewCellIdentifier];
    OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
    cell.itemLabel.text = [menuItem.title uppercaseStringWithLocale:[NSLocale currentLocale]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Hack : because others segues don't still exist
    if (indexPath.row < 2)
    {
        OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
        [self openControllerWithSegueIdentifier:menuItem.segueIdentifier];
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier
{
    UIViewController *nextViewController = [self.controllersDictionary objectForKey:segueIdentifier];
    if (nextViewController)
    {
        SWRevealViewController *revealViewController = self.revealViewController;
        if (nextViewController != self.revealViewController.frontViewController)
        {
            [revealViewController pushFrontViewController:nextViewController animated:YES];
        }
        else
        {
            [revealViewController revealToggle:self];
        }
    }
    else
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

/**************************************************************************************************/
#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![self.controllersDictionary objectForKey:segue.identifier])
    {
        [self.controllersDictionary setObject:segue.destinationViewController forKey:segue.identifier];
    }
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureControllersDictionary
{
    UIViewController *frontViewController = self.revealViewController.frontViewController;
    if (frontViewController)
    {
        [self.controllersDictionary setObject:frontViewController
                                       forKey:OTMenuViewControllerSegueMenuMapIdentifier];
    }
}

+ (NSArray *)createMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    // Map
    OTMenuItem *itemMap = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_map_title", @"")
                                            segueIdentifier:OTMenuViewControllerSegueMenuMapIdentifier];
    [menuItems addObject:itemMap];
    
    // My Meetings
    OTMenuItem *itemMyMeetings = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myMeetings_title", @"")
                                                   segueIdentifier:OTMenuViewControllerSegueMenuMyMeetingsIdentifier];
    [menuItems addObject:itemMyMeetings];
    
    // Practical Information
    OTMenuItem *itemPracticalInformation = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_practicalInformation_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuPracticalInformationIdentifier];
    [menuItems addObject:itemPracticalInformation];
    
    // Forum
    OTMenuItem *itemForum = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_forum_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuForumIdentifier];
    [menuItems addObject:itemForum];
    
    // Members
    OTMenuItem *itemMembers = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_members_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuMembersIdentifier];
    [menuItems addObject:itemMembers];
    
    // My Profile
    OTMenuItem *itemMyProfile = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myProfile_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuMyProfileIdentifier];
    [menuItems addObject:itemMyProfile];
    
    // My Notifications
    OTMenuItem *itemMyNotifications = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myNotifications_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuMyNotificationsIdentifier];
    [menuItems addObject:itemMyNotifications];
    
    // Help
    OTMenuItem *itemHelp = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_help_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuHelpIdentifier];
    [menuItems addObject:itemHelp];
    
    // Your opinion
    OTMenuItem *itemYourOpinion = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_yourOpinion_title", @"")
                                                             segueIdentifier:OTMenuViewControllerSegueMenuYourOpinionIdentifier];
    [menuItems addObject:itemYourOpinion];
    
    // Disconnect
    OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
                                                    segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
    [menuItems addObject:itemDisconnect];

    return menuItems;
}

- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath
{
    OTMenuItem *menuItem = nil;
    
    if (indexPath && (indexPath.row < self.menuItems.count)) {
        menuItem = [self.menuItems objectAtIndex:indexPath.row];
    }
    
    return menuItem;
}

@end
