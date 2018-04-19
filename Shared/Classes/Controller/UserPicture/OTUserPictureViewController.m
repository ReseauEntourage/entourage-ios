//
//  OTUserPictureViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserPictureViewController.h"
#import "UIView+entourage.h"
#import "OTPicturePreviewViewController.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "UIStoryboard+entourage.h"
#import "OTPhotoPickerBehavior.h"
#import "UIBarButtonItem+factory.h"
#import "NSUserDefaults+OT.h"
#import "entourage-Swift.h"

#define PREVIEW_PICTURE_SEGUE @"PreviewPictureSegue"

@interface OTUserPictureViewController ()

@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) IBOutlet OTPhotoPickerBehavior *photoPickerBehavior;

@end

@implementation OTUserPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    if (![NSUserDefaults standardUserDefaults].isTutorialCompleted)
        [self addIgnoreButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen09_6ChoosePhotoView"];
    
    if ([NSUserDefaults standardUserDefaults].isTutorialCompleted) {
        self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    }
    else {
        self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.isMovingFromParentViewController)
        [OTLogger logEvent:@"BackFromPhoto1"];
}

- (IBAction)pictureSelected:(id)sender {
    self.image = self.photoPickerBehavior.selectedImage;
    [self performSegueWithIdentifier:PREVIEW_PICTURE_SEGUE sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PREVIEW_PICTURE_SEGUE]) {
        OTPicturePreviewViewController *controller = (OTPicturePreviewViewController*)[segue destinationViewController];
        controller.image = self.image;
    }
}

#pragma mark - Ignore button

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore")
                                                          withTarget:self
                                                           andAction:@selector(ignore)
                                                             andFont:@"SFUIText-Bold"
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

- (void)ignore {
    [OTLogger logEvent:@"IgnorePhoto"];
    [self performSegueWithIdentifier:@"SkipPreviewSegue" sender:self];
}

@end
