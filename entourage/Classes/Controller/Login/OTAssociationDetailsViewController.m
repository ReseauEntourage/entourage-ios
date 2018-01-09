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
#import "UIImageView+entourage.h"

@interface OTAssociationDetailsViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewImage;
@property (nonatomic, weak) IBOutlet UITextView *txtTelephone;
@property (nonatomic, weak) IBOutlet UITextView *txtAddress;
@property (nonatomic, weak) IBOutlet UITextView *txtSite;
@property (nonatomic, weak) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblTelephone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTxtPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTxtAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblSite;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTxtSite;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblInfo;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblAssociationName;

@end

@implementation OTAssociationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = OTLocalizedString(@"userviewcontroller_title");
    self.viewImage.layer.borderWidth = 1;
    self.viewImage.layer.borderColor = [UIColor appGreyishColor].CGColor;
    [self.logoImageView setupFromUrl:self.association.largeLogoUrl withPlaceholder:@"badgeDefault"];
    self.lblAssociationName.text = self.association.name;
    self.txtDescription.text = self.association.descr;
    if((!self.association.phone || [self.association.phone isEqualToString:@""]) &&
       (!self.association.address || [self.association.address isEqualToString:@""]) &&
       (!self.association.websiteUrl || [self.association.websiteUrl isEqualToString:@""])) {
        self.heightView.constant =
        self.heightLblInfo.constant =
        self.heightLblPhone.constant =
        self.heightTxtPhone.constant =
        self.heightLblAddress.constant =
        self.heightTxtAddress.constant =
        self.heightLblSite.constant = 
        self.heightTxtSite.constant = 0;
    }
    else {
        if (self.association.phone && ![self.association.phone isEqualToString:@""]) {
            self.txtTelephone.text = self.association.phone;
            self.txtTelephone.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtTelephone.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
        }
        else {
            self.heightLblPhone.constant = 0;
            self.heightTxtPhone.constant = 0;
        }
    
        if (self.association.address && ![self.association.address isEqualToString:@""]) {
            self.txtAddress.text = self.association.address;
            self.txtAddress.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtAddress.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
        }
        else {
            self.heightLblAddress.constant = 0;
            self.heightTxtAddress.constant = 0;
        }
    
        if (self.association.websiteUrl && ![self.association.websiteUrl isEqualToString:@""]) {
            self.txtSite.text = self.association.websiteUrl;
            self.txtSite.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtSite.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
        }
        else {
            self.heightLblSite.constant = 0;
            self.heightTxtSite.constant = 0;
        }
    }
    [self setupCloseModal];
}

@end
