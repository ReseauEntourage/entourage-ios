//
//  OTMyEntouragesDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesDataSource.h"
#import "OTFeedsService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"
#import "OTMyEntouragesFilter.h"
#import "OTFeedItem.h"
#import "OTSavedMyEntouragesFilter.h"
#import "NSUserDefaults+OT.h"
#import "OTAppAppearance.h"
#import "entourage-Swift.h"

@interface OTMyEntouragesDataSource ()

@property (nonatomic) int pageNumber;
@property (nonatomic, strong) OTMyEntouragesFilter *currentFilter;


@end

#define DATA_PAGE_SIZE 20

@implementation OTMyEntouragesDataSource

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entourageUpdated:) name:kNotificationEntourageChanged object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialize {
    self.currentFilter = [OTMyEntouragesFilter new];
    [self updateItems:[NSArray new]];
    self.pageNumber = 1;
}

- (void)updateData {
    [self requestDataWithSuccess:^(NSArray *items) {
        [self.tableDataSource refresh];
    } orFailure:nil];
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

#pragma mark - OTFeedItemsFilterDelegate

- (void)filterChanged:(OTMyEntouragesFilter *)filter {
    if (filter == nil) {
        // cancel the changes the user made to the filter
        // by reinitialising it
        self.currentFilter = [OTMyEntouragesFilter new];
        return;
    }
    self.currentFilter = filter;
    [NSUserDefaults standardUserDefaults].savedMyEntouragesFilter = [OTSavedMyEntouragesFilter fromMyEntouragesFilter:self.currentFilter];
    [self.items removeAllObjects];
    [self.tableView reloadData];
    self.pageNumber = 1;
    [self requestDataWithSuccess:^(NSArray *items) {
        [self.tableDataSource refresh];
    } orFailure:nil];
}

#pragma mark - private methods

- (void)requestDataWithSuccess:(void(^)(NSArray *items))success orFailure:(void(^)(void))failure {
    [SVProgressHUD show];
    NSMutableDictionary *parameters = [self.currentFilter toDictionaryWithPageNumber:self.pageNumber andSize:DATA_PAGE_SIZE];
    [[OTFeedsService new] getMyFeedsWithParameters:parameters success:^(NSArray *items) {
        [self.items addObjectsFromArray:items];
        
        [self configureNoDataView];
        
        [SVProgressHUD dismiss];
        success(items);
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if(failure)
            failure();
    }];
}

- (void)entourageUpdated:(NSNotification *)notification {
    [self.tableDataSource refresh];
}

- (void)configureNoDataView {
    if (self.items.count == 0) {
        self.noDataView.hidden = NO;
        [self.tableView.superview bringSubviewToFront:self.noDataView];
    } else {
        self.noDataView.hidden = YES;
        [self.tableView.superview sendSubviewToBack:self.noDataView];
    }
    
    UIImage *image = [self.noDataRoundedBackground.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.noDataRoundedBackground.image = image;
    self.noDataRoundedBackground.tintColor = [OTAppAppearance colorForNoDataPlacholderImage];
    self.noDataTitle.textColor = [ApplicationTheme shared].titleLabelColor;
    self.noDataSubtitle.textColor = [OTAppAppearance colorForNoDataPlacholderText];
    
    if (self.currentFilter.isUnread) {
        self.noDataTitle.text = OTLocalizedString(@"no_unread_messages_title");
        self.noDataSubtitle.hidden = YES;
    } else {
        self.noDataTitle.text = OTLocalizedString(@"no_messages_title");
        self.noDataSubtitle.hidden = NO;
    }
}

@end
