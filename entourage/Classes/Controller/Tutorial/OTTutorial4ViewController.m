//
//  OTTutorial4ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial4ViewController.h"
#import "OTTutorialViewController.h"
#import "UIColor+entourage.h"

@interface OTTutorial4ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation OTTutorial4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Faites appel à vos voisins afin d’entourer une personne sans-abri. Créez une action avec le bouton :"];
    [attributedString addAttributes:@{
                                NSForegroundColorAttributeName: [UIColor appOrangeColor]
                                      } range:NSMakeRange(67, 33)];
    self.descriptionLabel.attributedText = attributedString;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [(OTTutorialViewController*)self.parentViewController enableScrolling:NO];
}

- (void)handleSwipeRight {
    [(OTTutorialViewController*)self.parentViewController showPreviousViewController:self];
    [(OTTutorialViewController*)self.parentViewController enableScrolling:YES];
}

- (IBAction)showPartnerSelection:(id)sender {
    UIStoryboard *userProfileStoryboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UIViewController *selectAssociationController = [userProfileStoryboard instantiateViewControllerWithIdentifier:@"SelectAssociation"];
    [self.navigationController pushViewController:selectAssociationController animated:YES];
}

- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
