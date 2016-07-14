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
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "NSUserDefaults+OT.h"

@interface OTOnboardingPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation OTOnboardingPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [self.btnDone setupHalfRoundedCorners];
    [self.imageView setImage:self.image];
    self.scrollView.layer.cornerRadius = self.scrollView.bounds.size.height / 2.0f;
    self.scrollView.layer.borderWidth = 2.0f;
    self.scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateMinZoomScaleForSize:self.view.bounds.size];
}

- (IBAction)doContinue {
#if SKIP_ONBOARDING_REQUESTS
    [self performSegueWithIdentifier:@"PreviewToGeoSegue" sender:self];
    return;
#endif
    UIImage *finalImage = [self cropVisibleArea];
    [SVProgressHUD show];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    [[OTPictureUploadService new] uploadPicture:finalImage withSuccess:^(NSString *pictureName) {
        currentUser.avatarKey = pictureName;
        [[OTAuthService new] updateUserInformationWithUser:currentUser success:^(OTUser *user) {
            [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationProfilePictureUpdated object:self];
            [SVProgressHUD dismiss];
            if (self.isOnboarding)
                [UIStoryboard showSWRevealController];
            else
                [self popToProfile];
        }
        failure:^(NSError *error) {
            NSDictionary *userInfo = [error userInfo];
            NSString *errorMessage = @"";
            NSDictionary *errorDictionary = [userInfo objectForKey:@"NSLocalizedDescription"];
            if (errorDictionary) {
                //NSString *code = [errorDictionary valueForKey:@"code"];
                errorMessage = ((NSArray*)[errorDictionary valueForKey:@"message"]).firstObject;
            }

            [SVProgressHUD showErrorWithStatus:errorMessage];
            NSLog(@"ERR: something went wrong on user picture: %@", error.description);
        }];
    } orError:^(NSError *error) {
        NSDictionary *userInfo = [error userInfo];
        NSString *errorMessage = [userInfo objectForKey:@"NSLocalizedDescription"];
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

- (void)popToProfile {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[OTUserEditViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}
- (UIImage*)cropVisibleArea {
    //Calculate the required area from the scrollview
    CGRect visibleRect;
    float scale = 1.0/self.scrollView.zoomScale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    UIImage *image = [self imageByCropping:self.imageView.image toRect:visibleRect];

    return image;
}

- (UIImage*)imageByCropping:(UIImage *)myImage toRect:(CGRect)cropToArea{
    CGImageRef cropImageRef = CGImageCreateWithImageInRect(myImage.CGImage, cropToArea);
    UIImage* cropped = [UIImage imageWithCGImage:cropImageRef];
    
    CGImageRelease(cropImageRef);
    return cropped;
}

#pragma UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)updateMinZoomScaleForSize:(CGSize)size {
    CGFloat widthScale = size.width / self.imageView.bounds.size.width;
    CGFloat heightScale = size.height / self.imageView.bounds.size.height;
    CGFloat minScale = MIN(widthScale, heightScale);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

@end
