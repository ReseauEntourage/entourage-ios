//
//  OTEditEntourageDescViewController.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageDescViewController.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"
#import "OTTextWithCount.h"
#import "entourage-Swift.h"

@interface OTEditEntourageDescViewController ()

@property (nonatomic, weak) IBOutlet OTTextWithCount *txtDescription;
@property (nonatomic, weak) IBOutlet UILabel *hintLabel;
@property (nonatomic, weak) IBOutlet UIImageView *hintIcon;

@end

@implementation OTEditEntourageDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor *secondaryColor = [UIColor appOrangeColor];
    UIColor *primaryColor =[UIColor whiteColor];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController withMainColor:primaryColor andSecondaryColor:secondaryColor];
    
    self.title = OTLocalizedString(@"descriptionTitle").uppercaseString;
    self.hintIcon.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    self.hintIcon.image = [self.hintIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.hintLabel.text = [OTAppAppearance addActionDescriptionHintMessage:self.currentEntourage.isOuting];
    
    if(self.currentEntourage.categoryObject.description_example != nil) {
        self.txtDescription.placeholder = self.currentEntourage.categoryObject.description_example;
    } else {
        if ([self.currentEntourage.type isEqualToString:@"ask_for_help"])
            self.txtDescription.placeholder = OTLocalizedString(@"edit_demand_desc");
        else {
            self.txtDescription.placeholder = OTLocalizedString(@"edit_contribution_desc");
        }
    }

    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(doneEdit)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:secondaryColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.txtDescription.textView.text = self.currentDescription;
    
    [self addBackButtonItem:secondaryColor];
}

-(void)addBackButtonItem:(UIColor*) secondaryColor {
    UIImage *menuImage = [[UIImage imageNamed:@"backItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *menuButtonCancel = [[UIBarButtonItem alloc] init];
    menuButtonCancel.image = menuImage;
    menuButtonCancel.tintColor = secondaryColor;
    [menuButtonCancel setTarget:self];
    [menuButtonCancel setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButtonCancel];
}

-(void)dismissModal {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.currentDescription.length > 0)
        [self.txtDescription updateAfterSpeech];
}

- (void)doneEdit {
    [self.delegate descriptionEdited:self.txtDescription.textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
