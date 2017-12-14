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
    self.parentArray = self.tableDataSource.parentArray;
    [self setupToolbarButtons];
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    [self setupCloseModalWithTarget:self andSelector:@selector(close)];
#if BETA
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
#endif
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(saveFilters)
                                                           andFont:@"SFUIText-Bold"    
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)saveFilters {
    [OTLogger logEvent:@"SubmitFilterPreferences"];
    OTFeedItemFilters *currentFilter = [self.tableDataSource readCurrentFilter];
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.filterDelegate filterChanged:currentFilter];
    }];
}

- (void)close {
    [OTLogger logEvent:@"CloseFilter"];
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
