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
}

/**************************************************************************************************/
#pragma mark - Private methods

+ (NSArray *)createMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    OTMenuItem *itemMap = [[OTMenuItem alloc] initWithTitle:@"Carte" segueIdentifier:@"segueMenuIdentifierForMap"];
    [menuItems addObject:itemMap];
    
    OTMenuItem *itemMyMeetings = [[OTMenuItem alloc] initWithTitle:@"Mes recontres" segueIdentifier:@"segueMenuIdentifierForMyMeetings"];
    [menuItems addObject:itemMyMeetings];
    
    OTMenuItem *itemPracticalInformation = [[OTMenuItem alloc] initWithTitle:@"Infos pratiques" segueIdentifier:@"segueMenuIdentifierForPracticalInformation"];
    [menuItems addObject:itemPracticalInformation];
    
    return menuItems;
}

- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath
{
    OTMenuItem *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    return menuItem;
}

@end
