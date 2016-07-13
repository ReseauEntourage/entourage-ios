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

@interface OTOnboardingPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewRightonstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;

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
    
    self.scrollView.layer.cornerRadius = self.scrollView.bounds.size.height / 2.0f;
    self.scrollView.layer.borderWidth = 2.0f;
    self.scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateMinZoomScaleForSize:self.view.bounds.size];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)doContinue {
    UIImage *futureImage = [self cropVisibleArea];
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
- (UIImage*)cropVisibleArea {
    //Calculate the required area from the scrollview
    CGRect visibleRect;
    float scale = 1.0/self.scrollView.zoomScale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    UIImage *image = [self imageByCropping:self.imageView.image toRect:visibleRect];
    //UIImage *image = imageFromView(imageView.image, &visibleRect);
    //[croppedImageImageView setImage:self.objPostPikUploadPhotoPage.croppedImage];
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
