//
//  OTAddActionFirstConsentViewController.m
//  entourage
//
//  Created by Smart Care on 05/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAddActionFirstConsentViewController.h"
#import "OTAddActionSecondConsentViewController.h"
#import "UIStoryboard+entourage.h"
#import "entourage-Swift.h"

@interface OTAddActionFirstConsentViewController ()
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@end

@implementation OTAddActionFirstConsentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = OTLocalizedString(@"final_question").uppercaseString;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Créez-vous cette action solidaire pour une personne identifiée, autre que vous : un ami en situation précaire, une personne croisée dans la rue ?"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont SFUITextWithSize:17 type:SFUITextFontTypeMedium] range:NSMakeRange(34, 44)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont SFUITextWithSize:17 type:SFUITextFontTypeSemibold] range:NSMakeRange(79, 1)];
    self.descriptionLabel.attributedText = attributedString;
}

- (IBAction)selectYesAction {
    UIStoryboard *storyboard = [UIStoryboard entourageEditorStoryboard];
    OTAddActionSecondConsentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTAddActionSecondConsentViewController"];
    vc.completionBlock = self.completionBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)selectNoForMeAction {
    self.completionBlock(OTAddActionConsentAnswerTypeAddForMe);
}

- (IBAction)selectNoForOrganisationAction {
    self.completionBlock(OTAddActionConsentAnswerTypeAddForOtherOrganisation);
}

@end
