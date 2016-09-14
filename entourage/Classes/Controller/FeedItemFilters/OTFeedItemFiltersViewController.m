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

#pragma mark - private methods

- (void)setupToolbarButtons {
    [self setupCloseModal];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString withTarget:self andAction:@selector(saveFilters) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)saveFilters {
    OTFeedItemFilters *currentFilter = [self.tableDataSource readCurrentFilter];
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.filterDelegate filterChanged:currentFilter];
    }];
}

@end
