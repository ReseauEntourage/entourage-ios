//
//  OTTutorial1ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTTutorial1ViewController.h"
#import "OTTutorialViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"

@implementation OTTutorial1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    self.headerView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Pour renseigner votre description, \naccédez à votre profil depuis le menu en bas à droite " attributes:@{
                                                                                                                                                                                                                NSFontAttributeName: [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold],
                                                                                                                                                                                                                NSForegroundColorAttributeName: [UIColor colorWithWhite:74.0f / 255.0f alpha:1.0f],
                                                                                                                                                                                                                NSKernAttributeName: @(0.0)
                                                                                                                                                                                                                }];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appOrangeColor] range:NSMakeRange(69, 4)];
    [self.descriptionLabel setAttributedText:attributedString];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
    
    [(OTTutorialViewController*)self.parentViewController enableScrolling:NO];
}

- (void)handleSwipeLeft {
    [(OTTutorialViewController*)self.parentViewController showNextViewController:self];
    [(OTTutorialViewController*)self.parentViewController enableScrolling:YES];
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
