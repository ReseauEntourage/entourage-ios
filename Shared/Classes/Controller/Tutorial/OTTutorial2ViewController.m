//
//  OTTutorial2ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTTutorial2ViewController.h"
#import "UIColor+entourage.h"
#import "entourage-Swift.h"

@interface OTTutorial2ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *lblDetails;

@end

@implementation OTTutorial2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Consultez les actions et les événements solidaires créés par vos voisins et rejoignez ceux qui vous intéressent sur la carte" attributes:@{
                                                                                                                                                                                                                                                 NSFontAttributeName: [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold],
                                                                                                                                                                                                                                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:74.0f / 255.0f alpha:1.0f],
                                                                                                                                                                                                                                                 NSKernAttributeName: @(0.0)
                                                                                                                                                                                                                                                 }];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appOrangeColor] range:NSMakeRange(76, 48)];
    
    self.lblDetails.attributedText = attributedString;
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
