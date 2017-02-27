//
//  OTAssociationDetailsViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/22/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationDetailsViewController.h"
#import "OTConsts.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"

@interface OTAssociationDetailsViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewImage;
@property (nonatomic, weak) IBOutlet UITextView *txtTelephone;
@property (nonatomic, weak) IBOutlet UITextView *txtAddress;
@property (nonatomic, weak) IBOutlet UITextView *txtSite;

@end

@implementation OTAssociationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = OTLocalizedString(@"userviewcontroller_title");
    self.viewImage.layer.borderWidth = 1;
    self.viewImage.layer.borderColor = [UIColor appGreyishColor].CGColor;
    self.txtTelephone.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtTelephone.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
    self.txtAddress.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtAddress.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
    self.txtSite.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtSite.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
    [self setupCloseModal];
}

@end
