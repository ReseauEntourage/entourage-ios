//
//  OTEntourageAddressBookViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInviteContactsViewController.h"
#import "SVProgressHUD.h"
#import "OTAddressBookItem.h"
#import "OTAddressBookService.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"

#define FULLNAME_CELL_TAG 1
#define SELECTED_IMAGE_CELL_TAG 2
#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@interface OTEntourageInviteContactsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) NSArray *quickJumpList;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *currentContacts;

@end

@implementation OTEntourageInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"contacts").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send") withTarget:self andAction:@selector(save) colored:[UIColor appOrangeColor]];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    self.tblContacts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tblContacts.sectionIndexColor = [UIColor appOrangeColor];
    [self loadContacts];
}

- (void)loadContacts {
    [SVProgressHUD show];
    [[OTAddressBookService new] readWithResultBlock:^(NSArray *results) {
        self.contacts = results;
        self.currentContacts = results;
        [self refreshDataSource];
        [self.tblContacts reloadData];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Contacts table view data source delegate implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.quickJumpList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.quickJumpList objectAtIndex:section];
    NSArray *items = [self.dataSource objectForKey:key];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.quickJumpList objectAtIndex:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.quickJumpList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    OTAddressBookItem *addressBookItem = [self getItemAtIndexPath:indexPath];
    UILabel *lblFullName = [cell viewWithTag:FULLNAME_CELL_TAG];
    lblFullName.text = addressBookItem.fullName;
    UIImageView *imgSelected = [cell viewWithTag:SELECTED_IMAGE_CELL_TAG];
    imgSelected.image = [[UIImage imageNamed:(addressBookItem.selected ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return cell;
}

#pragma mark - Contacts table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTAddressBookItem *item = [self getItemAtIndexPath:indexPath];
    item.selected = !item.selected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if(item.selected)
        [self.btnSave changeEnabled:YES];
    else
        [self checkIfDisable];
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchBar.text length] == 0)
        self.currentContacts = self.contacts;
    else
        self.currentContacts = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(OTAddressBookItem *item, NSDictionary * bndings) {
            NSRange rangeValue = [item.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            BOOL contains = rangeValue.length > 0;
            return contains;
        }]];
    [self refreshDataSource];
    [self.tblContacts reloadData];
}

#pragma mark - private members

- (void)refreshDataSource {
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *index = nil;
    for (OTAddressBookItem *item in self.currentContacts) {
        NSString *currentIndex = [item.fullName substringToIndex:1];
        if(!index || ![index isEqualToString:currentIndex]) {
            index = currentIndex;
            [sections addObject:currentIndex];
        }
        NSMutableArray *array = [data objectForKey:currentIndex];
        if(!array) {
            array = [NSMutableArray new];
            [data setObject:array forKey:currentIndex];
        }
        [array addObject:item];
    }
    self.dataSource = data;
    self.quickJumpList = sections;
}

- (OTAddressBookItem *)getItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self.quickJumpList objectAtIndex:indexPath.section];
    NSArray *items = [self.dataSource objectForKey:key];
    return [items objectAtIndex:indexPath.row];
}

- (void)save {
#warning TODO
}

- (void)checkIfDisable {
    NSArray *enabled = [self.currentContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(selected == YES)"]];
    if([enabled count] == 0)
        [self.btnSave changeEnabled:NO];
}

@end
