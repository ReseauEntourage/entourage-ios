//
//  OTTutorial3ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial3ViewController.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"

@implementation OTTutorial3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    self.headerView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:OTLocalizedString(@"Découvrez les conseils pratiques du guide Simple Comme Bonjour depuis le menu en haut à gauche :")];
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor
                                      } range:NSMakeRange(0, 32)];
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor
                                      } range:NSMakeRange(63, 14)];
    
    self.descriptionLabel.attributedText = attributedString;
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
