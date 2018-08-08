//
//  OTEditEntourageTitleViewController.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageTitleViewController.h"
#import "OTTextWithCount.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "OTConsts.h"
#import "entourage-Swift.h"

@interface OTEditEntourageTitleViewController () <TextWithCountDelegate>

@property (nonatomic, weak) IBOutlet OTTextWithCount *txtTitle;
@property (nonatomic, weak) IBOutlet UIView *hintView;
@property (nonatomic, weak) IBOutlet UIImageView *hintIcon;
@property (nonatomic, weak) IBOutlet UIView *maxLenghtReachedView;
@property (nonatomic, weak) IBOutlet UILabel *hintLabel;

@end

@implementation OTEditEntourageTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = OTLocalizedString(@"title").uppercaseString;
    
    self.hintLabel.text = [OTAppAppearance addActionTitleHintMessage];
    
    self.hintIcon.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    self.hintIcon.image = [self.hintIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if(self.currentEntourage.categoryObject.title_example != nil) {
        self.txtTitle.placeholder = self.currentEntourage.categoryObject.title_example;
        
    } else {
        if([self.currentEntourage.type isEqualToString:@"ask_for_help"])
            self.txtTitle.placeholder = OTLocalizedString(@"edit_demand_title");
    }

    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(doneEdit)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.txtTitle.maxLength = 100;
    self.txtTitle.textView.text = self.currentTitle;
    self.txtTitle.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(self.currentTitle && ![self.currentTitle isEqualToString:@""])
        [self.txtTitle updateAfterSpeech];
}

- (void)doneEdit {
    [self.delegate titleEdited:self.txtTitle.textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextWithCountDelegate

- (void)maxLengthReached:(BOOL)reached {
    self.hintView.hidden = reached;
    self.maxLenghtReachedView.hidden = !reached;
}

@end
