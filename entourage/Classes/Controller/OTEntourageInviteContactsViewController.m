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

@interface OTEntourageInviteContactsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTEntourageInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataSource initialize];
    [self.tableDataSource initialize];
    self.title = OTLocalizedString(@"contacts").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send") withTarget:self andAction:@selector(save) colored:[UIColor appOrangeColor]];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    self.tblContacts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tblContacts.sectionIndexColor = [UIColor appOrangeColor];
    [self loadContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (void)loadContacts {
    [SVProgressHUD show];
    [[OTAddressBookService new] readWithResultBlock:^(NSArray *results) {
        [self.dataSource updateItems:results];
        [self.tblContacts reloadData];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Contacts table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTAddressBookItem *item = [self.tableDataSource getItemAtIndexPath:indexPath];
    item.selected = !item.selected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if(item.selected)
        [self.btnSave changeEnabled:YES];
    else
        [self checkIfDisable];
}

#pragma mark - private members

- (void)save {
#warning TODO
}

- (void)checkIfDisable {
    NSArray *enabled = [self.dataSource.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(selected == YES)"]];
    if([enabled count] == 0)
        [self.btnSave changeEnabled:NO];
}

@end
