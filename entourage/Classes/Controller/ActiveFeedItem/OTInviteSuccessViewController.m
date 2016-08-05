//
//  OTInviteSuccessViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteSuccessViewController.h"

@implementation OTInviteSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self performSelector:@selector(close) withObject:nil afterDelay:5];
}

- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
