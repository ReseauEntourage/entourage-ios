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
#import "OTFeedItemFactory.h"
#import "NSString+Validators.h"

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
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray *success = [NSMutableArray new];
    NSMutableArray *failure = [NSMutableArray new];
    
    [SVProgressHUD show];
    dispatch_group_async(group, queue, ^() {
        NSArray *selectedItems = [self selectedItems];
        for(OTAddressBookItem *item in selectedItems) {
            dispatch_group_enter(group);
                [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] invitePhone:[item.telephone phoneNumberServerRepresentation] withSuccess:^() {
                    @synchronized (success) {
                        [success addObject:item.telephone];
                    }
                    dispatch_group_leave(group);
                } orFailure:^(NSError *error) {
                    @synchronized (failure) {
                        [failure addObject:item.telephone];
                    }
                    dispatch_group_leave(group);
                }];
        }
        dispatch_group_notify(group, queue, ^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if([failure count] > 0)  {
                    [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"inviteByPhoneFailed") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                    if(self.delegate)
                        [self.delegate didInviteWithSuccess];
                }
            });
        });
    });
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
