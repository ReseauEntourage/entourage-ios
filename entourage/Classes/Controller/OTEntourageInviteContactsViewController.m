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

@interface OTEntourageInviteContactsViewController () <UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *currentContacts;

@end

@implementation OTEntourageInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.groupedSource initialise];
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
        [self.dataProvider refreshSource:self.currentContacts];
        [self.tblContacts reloadData];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Contacts table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTAddressBookItem *item = [self.groupedSource getItemAtIndexPath:indexPath];
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
    [self.dataProvider refreshSource:self.currentContacts];
    [self.tblContacts reloadData];
}

#pragma mark - private members

- (void)save {
#warning TODO
}

- (void)checkIfDisable {
    NSArray *enabled = [self.currentContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(selected == YES)"]];
    if([enabled count] == 0)
        [self.btnSave changeEnabled:NO];
}

@end
