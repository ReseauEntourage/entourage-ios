//
//  OTTutorial3ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial3ViewController.h"
#import "UIColor+entourage.h"

@implementation OTTutorial3ViewController

- (IBAction)close:(id)sender {
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

@end
