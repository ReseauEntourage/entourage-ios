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

@interface OTOnboardingPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;


@end

@implementation OTOnboardingPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [self.btnDone setupHalfRoundedCorners];
    
    NSData *imageData = [NSData dataWithContentsOfURL:self.pictureUri];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.imageView setImage:image];
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
