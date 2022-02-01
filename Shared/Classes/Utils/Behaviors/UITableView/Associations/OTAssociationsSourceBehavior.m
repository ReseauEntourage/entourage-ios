//
//  OTAssociationsSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTAssociationsSourceBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTAssociationsService.h"
#import "OTTableDataSourceBehavior.h"
#import "OTAssociation.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

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

- (void)updateAssociation:(void (^)(void))success {
    OTAssociation *currentAssociation = [self getCurrentAssociation];
    if(currentAssociation == self.originalAssociation) {
        if(success)
            success();
        return;
    }
    [SVProgressHUD show];
    if(self.originalAssociation) {
        [[OTAssociationsService new] deleteAssociation:self.originalAssociation withSuccess:^(OTAssociation *updated) {
            [self updateUserAssociation:nil];
            if(currentAssociation == nil) {
                [SVProgressHUD dismiss];
                if(success)
                    success();
            }
            else
                [[OTAssociationsService new] addAssociation:currentAssociation withSuccess:^(OTAssociation *nUpdated) {
                    [self updateUserAssociation:currentAssociation];
                    [SVProgressHUD dismiss];
                    if(success)
                        success();
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"update_association_error")];
                }];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"update_association_error")];
        }];
    }
    else if(currentAssociation != nil)
        [[OTAssociationsService new] addAssociation:currentAssociation withSuccess:^(OTAssociation *nUpdated) {
            [self updateUserAssociation:currentAssociation];
            [SVProgressHUD dismiss];
            if(success)
                success();
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

- (void)updateUserAssociation:(OTAssociation *)association {
    self.originalAssociation = association;
    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
    user.partner = association;
    [NSUserDefaults standardUserDefaults].currentUser = user;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationSupportedPartnerUpdated object:self];
}

@end
