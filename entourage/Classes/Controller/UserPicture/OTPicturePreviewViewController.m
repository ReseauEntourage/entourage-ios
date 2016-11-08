//
//  OTPicturePreviewViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPicturePreviewViewController.h"
#import "OTUserEditViewController.h"
#import "UIStoryboard+entourage.h"
#import "SVProgressHUD.h"
#import "UIView+entourage.h"
#import "OTPictureUploadService.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "NSUserDefaults+OT.h"
#import "NSError+OTErrorData.h"
#import "NSUserDefaults+OT.h"
#import "UIImage+processing.h"

#define MaxImageSize 300

@interface OTPicturePreviewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation OTPicturePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    
    self.image = [self.image toSquare];
    [self.imageView setImage:self.image];
    self.scrollView.maximumZoomScale = 10;
}

- (IBAction)doContinue {
    [Flurry logEvent:@"SubmitInstantPhoto"];
    [SVProgressHUD show];
    UIImage *finalImage = [self cropVisibleArea];
    finalImage = [finalImage resizeTo:CGSizeMake(MaxImageSize, MaxImageSize)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tiny.png"];
    [UIImagePNGRepresentation(finalImage) writeToFile:filePath atomically:YES];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    [[OTPictureUploadService new] uploadPicture:finalImage withSuccess:^(NSString *pictureName) {
        currentUser.avatarKey = pictureName;
        [[OTAuthService new] updateUserInformationWithUser:currentUser success:^(OTUser *user) {
            // TODO phone is not in response so need to restore it manually
            user.phone = currentUser.phone;
            [NSUserDefaults standardUserDefaults].currentUser = user;
            self.scrollView.delegate = nil;
            if([NSUserDefaults standardUserDefaults].isTutorialCompleted)
                [self popToProfile];
            else
                [self performSegueWithIdentifier:@"PreviewToGeoSegue" sender:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationProfilePictureUpdated object:self];
            [SVProgressHUD dismiss];
        }
        failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_photo_change_error")];
            NSLog(@"ERR: something went wrong on user picture: %@", error.description);
        }];
    } orError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_photo_change_error")];
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
    float scale = 1.0 / self.scrollView.zoomScale;
    visibleRect.origin.x = self.scrollView.contentOffset.x / self.scrollView.contentSize.width * self.image.size.width;
    visibleRect.origin.y = self.scrollView.contentOffset.y / self.scrollView.contentSize.height * self.image.size.height;
    visibleRect.size.width = self.image.size.width * scale;
    visibleRect.size.height = self.image.size.height * scale;
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

@end
