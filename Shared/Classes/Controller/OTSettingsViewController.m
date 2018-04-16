//
//  OTSettingsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 24/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSettingsViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"

@implementation OTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString( @"parameters").uppercaseString;
    [self setupCloseModal];
}

@end
