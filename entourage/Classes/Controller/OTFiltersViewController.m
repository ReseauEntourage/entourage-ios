//
//  OTFiltersViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFiltersViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"

@implementation OTFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  OTLocalizedString(@"filters").uppercaseString;
    
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"save").capitalizedString
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(saveFilters)];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)saveFilters {
    
}

@end
