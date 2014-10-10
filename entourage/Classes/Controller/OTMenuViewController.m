//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuViewController.h"

NSString *const OTMenuTableViewCellIdentifier = @"OTMenuTableViewCellIdentifier";

/**************************************************************************************************/
// OTMenuTableViewCell
/**************************************************************************************************/

@interface OTMenuTableViewCell : UITableViewCell

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, weak) IBOutlet UILabel *itemLabel;

@end

@implementation OTMenuTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.itemLabel.highlighted = highlighted;
}

@end

/**************************************************************************************************/
// OTMenuItem
/**************************************************************************************************/

@interface OTMenuItem : NSObject

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *segueIdentifier;

/**************************************************************************************************/
#pragma mark - Birth and Death

- (instancetype)initWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier;

@end

@implementation OTMenuItem

/**
 * Init OTMenuItem with title and segueIdentifier
 *
 * @param title
 * The title to display in menu
 *
 * @param segueIdentifier
 * The segueIdentifier corresponding to Main.storyboard to naviguate in different items menu
 *
 * @return OTMenuItem created
 */
- (instancetype)initWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier
{
    self = [super init];
    
    if (self)
    {
        _title = title;
        _segueIdentifier = segueIdentifier;
    }
    
    return self;
}

@end

/**************************************************************************************************/
// OTMenuViewController
/**************************************************************************************************/

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

/**************************************************************************************************/
#pragma mark - Getters and Setters

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = [OTMenuViewController createMenuItems];
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
    
    if (indexPath.row < 1)
    {
        OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
        [self openControllerWithSegueIdentifier:menuItem.segueIdentifier];
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier
{
    [self performSegueWithIdentifier:segueIdentifier sender:self];
}

/**************************************************************************************************/
#pragma mark - Private methods

+ (NSArray *)createMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    // Map
    OTMenuItem *itemMap = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_map_title", @"")
                                            segueIdentifier:@"segueMenuIdentifierForMap"];
    [menuItems addObject:itemMap];
    
    // My Meetings
    OTMenuItem *itemMyMeetings = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myMeetings_title", @"")
                                                   segueIdentifier:@"segueMenuIdentifierForMyMeetings"];
    [menuItems addObject:itemMyMeetings];
    
    // Practical Information
    OTMenuItem *itemPracticalInformation = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_practicalInformation_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForPracticalInformation"];
    [menuItems addObject:itemPracticalInformation];
    
    // Forum
    OTMenuItem *itemForum = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_forum_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForForum"];
    [menuItems addObject:itemForum];
    
    // Members
    OTMenuItem *itemMembers = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_members_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForMembers"];
    [menuItems addObject:itemMembers];
    
    // My Profile
    OTMenuItem *itemMyProfile = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myProfile_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForMyProfile"];
    [menuItems addObject:itemMyProfile];
    
    // My Notifications
    OTMenuItem *itemMyNotifications = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_myNotifications_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForMyNotifications"];
    [menuItems addObject:itemMyNotifications];
    
    // Help
    OTMenuItem *itemHelp = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_help_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForHelp"];
    [menuItems addObject:itemHelp];
    
    // Your opinion
    OTMenuItem *itemYourOpinion = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_yourOpinion_title", @"")
                                                             segueIdentifier:@"segueMenuIdentifierForYourOpinion"];
    [menuItems addObject:itemYourOpinion];
    
    // Disconnect
    OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
                                                    segueIdentifier:@"segueMenuIdentifierForDisconnect"];
    [menuItems addObject:itemDisconnect];

    return menuItems;
}


- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath
{
    OTMenuItem *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    return menuItem;
}

@end
