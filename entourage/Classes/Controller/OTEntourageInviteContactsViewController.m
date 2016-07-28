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

#define FULLNAME_CELL_TAG 0

@interface OTEntourageInviteContactsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContacts;

@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) NSArray *quickJumpList;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *currentContacts;

@end

@implementation OTEntourageInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - Contacts table view data source implementation

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
    
    NSString *key = [self.quickJumpList objectAtIndex:indexPath.section];
    NSArray *items = [self.dataSource objectForKey:key];
    OTAddressBookItem *addressBookItem = [items objectAtIndex:indexPath.row];
    
    UILabel *lblFullName = [cell viewWithTag:FULLNAME_CELL_TAG];
    lblFullName.text = addressBookItem.fullName;
    
    return cell;
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

#pragma mark - build source

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

@end
