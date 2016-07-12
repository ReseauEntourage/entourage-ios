//
//  OTUserEditPictureViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserEditPictureViewController.h"
#import "UIViewController+menu.h"
#import "UIView+entourage.h"

@interface OTUserEditPictureViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnFromGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePicture;

@end

@implementation OTUserEditPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnFromGallery setupHalfRoundedCorners];
    [self.btnTakePicture setupHalfRoundedCorners];
    [self setupCloseModal];
}

- (void) pictureUrlSelected:(NSURL *)uri {
    
}

@end
