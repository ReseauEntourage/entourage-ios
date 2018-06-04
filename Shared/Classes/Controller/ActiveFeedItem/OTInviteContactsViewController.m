//
//  OTInviteContactsViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTInviteContactsViewController.h"
#import "OTAddressBookPhone.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "NSString+Validators.h"
#import "OTContactsFilteredDataSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTContactPhoneCell.h"
#import "entourage-Swift.h"

@interface OTInviteContactsViewController () <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet OTContactsFilteredDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableDataSource initialize];
    self.title = OTLocalizedString(@"contacts").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send")
                                         withTarget:self
                                          andAction:@selector(save)
                                            andFont:@"SFUIText-Bold"
                                            colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    self.tblContacts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tblContacts.sectionIndexColor = [UIColor appOrangeColor];
    [self.dataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
}

#pragma mark - Contacts table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[OTContactPhoneCell class]]) {
        OTAddressBookPhone *item = [self.tableDataSource getItemAtIndexPath:indexPath];
        item.selected = !item.selected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if(item.selected)
            [self.btnSave changeEnabled:YES];
        else
            [self checkIfDisable];
    }
}

#pragma mark - private members

- (void)save {
    [SVProgressHUD show];
    NSArray *selectedPhones = [self selectedItems];
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] invitePhones:selectedPhones withSuccess:^() {
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        if(self.delegate)
            [self.delegate didInviteWithSuccess];
    } orFailure:^(NSError *error, NSArray *failedNUmbers) {
        [SVProgressHUD dismiss];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"inviteByPhoneFailed") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)checkIfDisable {
    NSArray *selectedItems = [self selectedItems];
    if([selectedItems count] == 0)
        [self.btnSave changeEnabled:NO];
}

- (NSArray *)selectedItems {
    NSMutableArray *result = [NSMutableArray new];
    for(id item in self.dataSource.items) {
        if(![item isKindOfClass:[OTAddressBookPhone class]])
            continue;
        OTAddressBookPhone *phone = (OTAddressBookPhone *)item;
        if(phone.selected)
            [result addObject:phone.telephone];
    }
    return result;
}

@end
