//
//  OTFeedItemFiltersViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemFiltersViewController.h"
#import "OTConsts.h"
#import "UIViewController+menu.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"
#import "OTFeedItemsFiltersTableDataSource.h"
#import "entourage-Swift.h"

@interface OTFeedItemFiltersViewController ()

@property (nonatomic, strong) NSArray *parentArray;
@property (strong, nonatomic) IBOutlet OTFeedItemsFiltersTableDataSource *tableDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OTFeedItemFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableDataSource initializeWith:self.filterDelegate.currentFilter];
    self.title =  OTLocalizedString(@"filters").uppercaseString;
    self.tableView.tableFooterView = [UIView new];
    [self setupToolbarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentArray = self.tableDataSource.parentArray;
    [self.tableView reloadData];
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    [self setupCloseModalWithTarget:self andSelector:@selector(close)];

    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(saveFilters)
                                                           andFont:@"SFUIText-Bold"    
                                                           colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)saveFilters {
    [OTLogger logEvent:@"SubmitFilterPreferences"];
    OTFeedItemFilters *currentFilter = [self.tableDataSource readCurrentFilter];
    
    [self dismissViewControllerAnimated:YES completion:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.filterDelegate filterChanged:currentFilter];
        });
    }];
}

- (void)close {
    [OTLogger logEvent:@"CloseFilter"];
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.filterDelegate filterChanged:nil];
        });
    }];
}

@end
