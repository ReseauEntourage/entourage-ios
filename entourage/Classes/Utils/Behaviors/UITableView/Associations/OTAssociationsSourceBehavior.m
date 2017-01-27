//
//  OTAssociationsSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationsSourceBehavior.h"
#import "SVProgressHUD.h"
#import "OTAssociationsService.h"
#import "OTTableDataSourceBehavior.h"
#import "OTAssociation.h"
#import "OTConsts.h"

@interface OTAssociationsSourceBehavior ()

@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) OTAssociation *originalAssociation;

@end

@implementation OTAssociationsSourceBehavior

@synthesize items;

- (void)filterItemsByString:(NSString *)searchString {
    if([searchString length] == 0)
        self.items = self.allItems;
    else
        self.items = [self.allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(OTAssociation *item, NSDictionary * bindings) {
            NSRange rangeValue = [item.name rangeOfString:searchString options:NSCaseInsensitiveSearch];
            BOOL contains = rangeValue.length > 0;
            return contains;
        }]];
    [self.tableDataSource refresh];
}

- (void)loadData {
    [SVProgressHUD show];
    [[OTAssociationsService new] getAllAssociationsWithSuccess:^(NSArray *associationItems) {
        [SVProgressHUD dismiss];
        [super updateItems:associationItems];
        self.items = associationItems;
        [self storeOriginalSuppportedAssociation];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)updateAssociation {
    OTAssociation *currentAssociation = [self getCurrentAssociation];
    if(currentAssociation == self.originalAssociation)
        return;
    [SVProgressHUD show];
    if(self.originalAssociation) {
        [[OTAssociationsService new] updateAssociation:self.originalAssociation isDefault:NO withSuccess:^(OTAssociation *updated) {
            if(currentAssociation == nil)
                [SVProgressHUD dismiss];
            else
                [[OTAssociationsService new] updateAssociation:currentAssociation isDefault:YES withSuccess:^(OTAssociation *nUpdated) {
                    [SVProgressHUD dismiss];
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"update_association_error")];
                }];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"update_association_error")];
        }];
    }
    else if(currentAssociation != nil)
        [[OTAssociationsService new] updateAssociation:currentAssociation isDefault:YES withSuccess:^(OTAssociation *nUpdated) {
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"update_association_error")];
        }];
}

#pragma mark - private methods

- (void)storeOriginalSuppportedAssociation {
    for(OTAssociation *association in self.items)
        if(association.isDefault) {
            self.originalAssociation = association;
            break;
        }
}

- (OTAssociation *)getCurrentAssociation {
    NSArray *defaultAssociations = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault==1"]];
    return defaultAssociations.count > 0 ? defaultAssociations.firstObject : nil;
}

@end
