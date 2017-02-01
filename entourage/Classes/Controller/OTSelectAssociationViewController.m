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

@interface OTSelectAssociationViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tblAssociations;
@property (nonatomic, weak) IBOutlet OTAssociationsSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;

@end

@implementation OTSelectAssociationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableDataSource initialize];
    self.title = OTLocalizedString(@"select_association_title").uppercaseString;
    self.tblAssociations.tableFooterView = [UIView new];
    [self setupToolbarButtons];
    [self.dataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
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
    UIBarButtonItem *saveButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString withTarget:self andAction:@selector(saveAssociation) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)saveAssociation {
    [self.dataSource updateAssociation:^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
