//
//  OTAddActionConfidentialityViewController.m
//  entourage
//
//  Created by Smart Care on 11/10/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTAddActionConfidentialityViewController.h"

@interface OTAddActionConfidentialityViewController ()

@end

@implementation OTAddActionConfidentialityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = OTLocalizedString(@"confidentiality_title").uppercaseString;
}

- (IBAction)preferValidationAction {
    self.completionBlock(YES);
}

- (IBAction)preferNoValidationAction {
    self.completionBlock(NO);
}

@end
