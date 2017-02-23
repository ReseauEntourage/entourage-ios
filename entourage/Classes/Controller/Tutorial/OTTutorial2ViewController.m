//
//  OTTutorial2ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial2ViewController.h"
#import "UIColor+entourage.h"

@interface OTTutorial2ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *lblDetails;

@end

@implementation OTTutorial2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:self.lblDetails.text];
    NSString *replaceString = @"entourages";
    NSRange range = [self.lblDetails.text rangeOfString:replaceString];
    [newText setAttributes:@{ NSForegroundColorAttributeName : [UIColor appOrangeColor] } range:range];
    self.lblDetails.attributedText = newText;
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
