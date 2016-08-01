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

#define PREVIEW_PICTURE_SEGUE @"PreviewPictureSegue"

@interface OTUserPictureViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnFromGallery;
@property (nonatomic, weak) IBOutlet UIButton *btnTakePicture;
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) IBOutlet OTPhotoPickerBehavior *photoPickerBehavior;

@end

@implementation OTUserPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    if (self.isOnboarding)
        [self addIgnoreButton];
    else
        self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    [self.btnFromGallery setupHalfRoundedCorners];
    [self.btnTakePicture setupHalfRoundedCorners];
}

- (IBAction)pictureSelected:(id)sender {
    self.image = self.photoPickerBehavior.selectedImage;
    [self performSegueWithIdentifier:PREVIEW_PICTURE_SEGUE sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PREVIEW_PICTURE_SEGUE]) {
        OTPicturePreviewViewController *controller = (OTPicturePreviewViewController*)[segue destinationViewController];
        controller.isOnboarding = self.isOnboarding;
        controller.image = self.image;
    }
}

#pragma mark - Ignore button

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore") withTarget:self andAction:@selector(ignore) colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

- (void)ignore {
    [self performSegueWithIdentifier:@"SkipPreviewSegue" sender:self];
}

@end
