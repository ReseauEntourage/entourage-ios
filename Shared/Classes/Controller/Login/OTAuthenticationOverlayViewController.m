//
//  AuthenticationOverlayViewController.m
//  entourage
//
//  Created by Grégoire Clermont on 06/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTAuthenticationOverlayViewController.h"

@interface OTAuthenticationOverlayViewController ()

@end

@implementation OTAuthenticationOverlayViewController

- (IBAction)tappedBackdrop:(id)sender {
    [self.delegate authenticationCanceled];
}

@end
