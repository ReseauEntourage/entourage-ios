//
//  OTTutorial1ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial1ViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"

@implementation OTTutorial1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Pour renseigner votre description, accédez à votre profil depuis le bouton menu en haut à gauche : "];
    [attributedString addAttributes:@{
                                      NSFontAttributeName: self.descriptionLabel.font,
                                      NSForegroundColorAttributeName: [UIColor appOrangeColor]
                                      } range:NSMakeRange(35, 44)];
    [self.descriptionLabel setAttributedText:attributedString];
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
