//
//  OTMyEntouragesFiltersViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFiltersViewController.h"
#import "OTConsts.h"
#import "UIViewController+menu.h"
#import "UIBarButtonItem+factory.h"
#import "UIColor+entourage.h"

@implementation OTMyEntouragesFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  OTLocalizedString(@"filters").uppercaseString;
    [self setupToolbarButtons];
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    [self setupCloseModal];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString withTarget:self andAction:@selector(saveFilters) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)saveFilters {
    
}

@end
