//
//  OTUserPicturePreviewViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingPreviewViewController.h"
#import "OTUserEditViewController.h"
#import "UIStoryboard+entourage.h"
#import "SVProgressHUD.h"
#import "UIView+entourage.h"
#import "OTPictureUploadService.h"

@interface OTOnboardingPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;


@end

@implementation OTOnboardingPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [self.btnDone setupHalfRoundedCorners];
    [self.imageView setImage:self.image];
    /* FOR TESTING
    [SVProgressHUD show];
    [[OTPictureUploadService new] uploadPicture:self.image withSuccess:^(NSString *pictureName) {
        [SVProgressHUD dismiss];
    } orError:^(void) {
        [SVProgressHUD dismiss];
    }];*/
}

- (IBAction)doContinue {
    [SVProgressHUD show];
    if (self.isOnboarding)
        [UIStoryboard showSWRevealController];
    else
        [self popToProfile];
    [SVProgressHUD dismiss];
}

- (void)popToProfile {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[OTUserEditViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

@end
