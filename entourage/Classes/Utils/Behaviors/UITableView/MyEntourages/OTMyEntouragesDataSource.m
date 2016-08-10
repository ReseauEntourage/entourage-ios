//
//  OTMyEntouragesDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesDataSource.h"
#import "OTFeedsService.h"
#import "SVProgressHUD.h"
#import "OTTableDataSourceBehavior.h"

@interface OTMyEntouragesDataSource ()

@property (nonatomic) int pageNumber;
@property (nonatomic, strong) OTMyEntouragesFilter *currentFilter;

@end

#define DATA_PAGE_SIZE 20

@implementation OTMyEntouragesDataSource

- (void)initialize {
    self.currentFilter = [OTMyEntouragesFilter new];
    [self updateItems:[NSArray new]];
    self.pageNumber = 1;
}

- (void)loadData {
    [self filterChanged:self.currentFilter];
}

- (void)loadNextPage {
    self.pageNumber++;
    [self requestDataWithSuccess:^(NSArray *items) {
        if([items count] == 0) {
            if(self.pageNumber > 1)
                self.pageNumber--;
        }
        else {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.items.count - items.count, items.count)];
            [self.tableView beginUpdates];
            [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    } orFailure:^() {
        self.pageNumber--;
    }];
}

#pragma mark - OTMyEntouragesFilterDelegate

- (void)filterChanged:(OTMyEntouragesFilter *)filter {
    self.currentFilter = filter;
    [self.items removeAllObjects];
    self.pageNumber = 1;
    [self requestDataWithSuccess:^(NSArray *items) {
        [self.tableDataSource refresh];
    } orFailure:nil];
}

#pragma mark - private methods

- (void)requestDataWithSuccess:(void(^)(NSArray *items))success orFailure:(void(^)())failure {
    [SVProgressHUD show];
    NSMutableDictionary *parameters = [self.currentFilter toDictionaryWithPageNumber:self.pageNumber andSize:DATA_PAGE_SIZE];
    [[OTFeedsService new] getMyFeedsWithParameters:parameters success:^(NSArray *items) {
        [SVProgressHUD dismiss];
        [self.items addObjectsFromArray:items];
        success(items);
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if(failure)
            failure();
    }];
}

@end
