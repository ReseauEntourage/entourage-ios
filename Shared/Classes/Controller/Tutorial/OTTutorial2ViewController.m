//
//  OTTutorial2ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
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
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Consultez les actions créées par vos voisins et rejoignez celles qui vous intéressent depuis la carte : "];
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName: [UIColor appGreyishBrownColor]
                                      } range:NSMakeRange(0, 47)];
    
    self.lblDetails.attributedText = attributedString;
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
