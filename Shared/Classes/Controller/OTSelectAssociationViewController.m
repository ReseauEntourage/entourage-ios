//
//  OTSelectAssociationViewController.m
//  entourage
//
//  Created by sergiu buceac on 1/16/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSelectAssociationViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "OTAssociationsSourceBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTAssociation.h"
#import "SVProgressHUD.h"
#import "OTAssociationDetailsViewController.h"
#import "entourage-Swift.h"

@interface OTSelectAssociationViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tblAssociations;
@property (nonatomic, weak) IBOutlet OTAssociationsSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (nonatomic, weak) IBOutlet UITextView *txtAssociationMissing;

@end

@implementation OTSelectAssociationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txtAssociationMissing.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor appOrangeColor]};
    [self.tableDataSource initialize];
    self.title = OTLocalizedString(@"select_association_title").uppercaseString;
    self.tblAssociations.tableFooterView = [UIView new];
    [self setupToolbarButtons];
    [self.dataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
}

#pragma mark - Associations table view delegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTAssociation *item = (OTAssociation *)[self.tableDataSource getItemAtIndexPath:indexPath];
    item.isDefault = !item.isDefault;
    for(OTAssociation *association in self.dataSource.items)
        if(association != item)
            association.isDefault = NO;
    [tableView reloadData];
}

#pragma mark - private methods

- (void)setupToolbarButtons {

    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    
    UIBarButtonItem *saveButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(saveAssociation)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)saveAssociation {
    BOOL hasAssociationSet = NO;
    for(OTAssociation *association in self.dataSource.items)
        hasAssociationSet = hasAssociationSet || association.isDefault;
    [self.dataSource updateAssociation:^() {
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(hasAssociationSet ? @"association_set" : @"association_reset")];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAssociationUpdated object:nil];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"AssociationDetails"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTAssociationDetailsViewController *associationController = (OTAssociationDetailsViewController *)controller.topViewController;
        NSIndexPath *indexPath = [self.tblAssociations indexPathForCell:(UITableViewCell *)sender];
        OTAssociation *item = (OTAssociation *)[self.dataSource.items objectAtIndex:indexPath.row];
        associationController.association = item;
    }
}

@end
