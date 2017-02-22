//
//  OTTutorial1ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial1ViewController.h"
#import "OTConsts.h"

@implementation OTTutorial1ViewController

- (IBAction)gotoBlog:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TUTORIAL_BLOG_LINK]];
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
