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

@interface OTEditEntourageDescViewController ()

@property (nonatomic, weak) IBOutlet OTTextWithCount *txtDescription;

@end

@implementation OTEditEntourageDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = OTLocalizedString(@"descriptionTitle").uppercaseString;
    if([self.currentEntourage.type isEqualToString:@"ask_for_help"])
        self.txtDescription.placeholder = OTLocalizedString(@"edit_demand_desc");
    else
        self.txtDescription.placeholder = OTLocalizedString(@"edit_contribution_desc");
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate") withTarget:self andAction:@selector(doneEdit) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.txtDescription.textView.text = self.currentDescription;
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
