//
//  OTInviteContactsViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteContactsViewController.h"
#import "SVProgressHUD.h"
#import "OTAddressBookItem.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "NSString+Validators.h"
#import "OTDataSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"

@interface OTInviteContactsViewController () <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTInviteContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableDataSource initialize];
    self.title = OTLocalizedString(@"contacts").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send") withTarget:self andAction:@selector(save) colored:[UIColor appOrangeColor]];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    self.tblContacts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tblContacts.sectionIndexColor = [UIColor appOrangeColor];
    [self.dataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
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
    [SVProgressHUD show];
    NSArray *selectedItems = [self selectedItems];
    NSMutableArray *phones = [NSMutableArray new];
    for(OTAddressBookItem *item in selectedItems)
        [phones addObject:item.telephone];
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] invitePhones:phones withSuccess:^() {
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        if(self.delegate)
            [self.delegate didInviteWithSuccess];
    } orFailure:^(NSError *error, NSArray *failedNUmbers) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"inviteByPhoneFailed") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
}

- (void)checkIfDisable {
    NSArray *selectedItems = [self selectedItems];
    if([selectedItems count] == 0)
        [self.btnSave changeEnabled:NO];
}

- (NSArray *)selectedItems {
    return [self.dataSource.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(selected == YES)"]];
}

@end
