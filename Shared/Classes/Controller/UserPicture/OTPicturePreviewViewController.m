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
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+entourage.h"
#import "OTPictureUploadService.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "NSUserDefaults+OT.h"
#import "NSUserDefaults+OT.h"
#import "UIImage+processing.h"
#import "OTGeolocationRightsViewController.h"
#import "entourage-Swift.h"

#define MaxImageSize 300

@interface OTPicturePreviewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation OTPicturePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;

    self.image = [self.image toSquare];
    [self.imageView setImage:self.image];
    self.scrollView.maximumZoomScale = 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen09_9MovePhotoView"];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"SubmitInstantPhoto"];
    [SVProgressHUD show];
    UIImage *finalImage = [self cropVisibleArea];
    finalImage = [finalImage resizeTo:CGSizeMake(MaxImageSize, MaxImageSize)];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tiny.png"];
    [UIImagePNGRepresentation(finalImage) writeToFile:filePath atomically:YES];

    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    [[OTPictureUploadService new] uploadPicture:finalImage
                                    withSuccess:^(NSString *pictureName) {
        currentUser.avatarKey = pictureName;
        [[OTAuthService new] updateUserInformationWithUser:currentUser success:^(OTUser *user) {
            
            // TODO phone is not in response so need to restore it manually
            user.phone = currentUser.phone;
            [NSUserDefaults standardUserDefaults].currentUser = user;
            self.scrollView.delegate = nil;
            
            if (([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
                [NSUserDefaults standardUserDefaults].isTutorialCompleted &&
                 [currentUser hasActionZoneDefined]) ||
                self.isEditingPictureForCurrentUser) {
                [self popToProfile];
                
            } else if (![currentUser hasActionZoneDefined]) {
                [self performSegueWithIdentifier:@"PreviewToGeoSegue" sender:self];
                
            } else {
                [OTAppState navigateToPermissionsScreens];
            }
                
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationProfilePictureUpdated object:self];
            [SVProgressHUD dismiss];
        }
        failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_photo_change_error")];
            NSLog(@"ERR: something went wrong on user picture: %@", error.localizedDescription);
        }];
                                        
    } orError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_photo_change_error")];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PreviewToGeoSegue"]) {
        OTGeolocationRightsViewController *controller = (OTGeolocationRightsViewController *)segue.destinationViewController;
        controller.isShownOnStartup = YES;
    }
}

- (void)popToProfile {
    BOOL profileFound = NO;
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[OTUserEditViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            profileFound = YES;
            break;
        }
    }
    
    if (!profileFound) {
        [OTAppState navigateToAuthenticatedLandingScreen];
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
