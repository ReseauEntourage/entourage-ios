//
//  OTUserEditPictureViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingPictureViewController.h"
#import "UIView+entourage.h"
#import "OTOnboardingPreviewViewController.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "UIStoryboard+entourage.h"

#define PREVIEW_PICTURE_SEGUE @"PreviewPictureSegue"

@interface OTOnboardingPictureViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnFromGallery;
@property (nonatomic, weak) IBOutlet UIButton *btnTakePicture;
@property (nonatomic, strong) UIImage *image;

@end

@implementation OTOnboardingPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    if (self.isOnboarding)
        [self addIgnoreButton];
    [self.btnFromGallery setupHalfRoundedCorners];
    [self.btnTakePicture setupHalfRoundedCorners];
}

- (void) pictureSelected:(UIImage *)image {
    self.image = image;
    [self performSegueWithIdentifier:PREVIEW_PICTURE_SEGUE sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PREVIEW_PICTURE_SEGUE]) {
        OTOnboardingPreviewViewController *controller = (OTOnboardingPreviewViewController*)[segue destinationViewController];
        controller.isOnboarding = self.isOnboarding;
        controller.image = self.image;
    }
}

#pragma mark - Ignore button

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"doIgnore")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(ignore)];
    [ignoreButton setTintColor:[UIColor whiteColor]];
    [ignoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

- (void)ignore {
    [UIStoryboard showSWRevealController];
}

@end
