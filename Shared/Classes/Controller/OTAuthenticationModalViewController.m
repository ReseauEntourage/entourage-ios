//
//  OTAuthenticationModalViewController.m
//  entourage
//
//  Created by Grégoire Clermont on 14/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTAuthenticationModalViewController.h"
#import "OTAppState.h"
#import "UINavigationController+entourage.h"

@interface OTAuthenticationModalViewController ()

@end

@implementation OTAuthenticationModalViewController

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.modal = [[[NSBundle mainBundle] loadNibNamed:@"AuthenticationModal"
                                                owner:self
                                              options:nil]
                  firstObject];;

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController presentTransparentNavigationBar];
}

- (IBAction)signup {
    [OTAppState continueFromStartupScreen:self creatingUser:YES];
}

- (IBAction)login {
    [OTAppState continueFromStartupScreen:self creatingUser:NO];
}

@end
