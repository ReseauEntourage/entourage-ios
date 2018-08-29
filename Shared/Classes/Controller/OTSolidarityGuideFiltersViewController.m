//
//  OTSolidarityGuideFiltersViewController.m
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFiltersViewController.h"
#import "OTSolidarityGuideFiltersTableDataSource.h"
#import "OTConsts.h"
#import "UIViewController+menu.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"
#import "OTFeedItemsFiltersTableDataSource.h"
#import "entourage-Swift.h"

@interface OTSolidarityGuideFiltersViewController ()

@property (strong, nonatomic) IBOutlet OTSolidarityGuideFiltersTableDataSource *tableDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OTSolidarityGuideFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableDataSource initializeWith:self.filterDelegate.solidarityFilter];
    self.title =  OTLocalizedString(@"filters").uppercaseString;
    self.tableView.tableFooterView = [UIView new];
    [self setupToolbarButtons];
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    [self setupCloseModalWithTarget:self andSelector:@selector(close)];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(saveFilters)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)saveFilters {
    [OTLogger logEvent:@"SubmitFilterPreferences"];
    OTSolidarityGuideFilter *currentFilter = [self.tableDataSource readCurrentFilter];
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.filterDelegate solidarityFilterChanged:currentFilter];
    }];
}

- (void)close {
    [OTLogger logEvent:@"CloseFilter"];
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
