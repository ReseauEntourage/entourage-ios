//
//  OTPhotoPickerBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTPhotoPickerBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface OTPhotoPickerBehavior () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation OTPhotoPickerBehavior

- (void)pickFromCamera:(UIButton *)sender {
    [OTLogger logEvent:@"Screen09_7TakePhotoView"];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        [self pickPhotoFromSource:UIImagePickerControllerSourceTypeCamera];
    
}

- (void)pickFromGallery:(UIButton *)sender {
    [OTLogger logEvent:@"PhotoUploadSubmit"];
    [self pickPhotoFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)pickPhotoFromSource:(UIImagePickerControllerSourceType)sourceType {
    [OTLogger logEvent:@"PhotoTakeSubmit"];
    UIImagePickerController *controller = [UIImagePickerController new];
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    controller.sourceType = sourceType;
    controller.delegate = self;
    [self.owner presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self notifyPictureSelected:[self rotateImage:img]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyPictureSelected:(UIImage *)image {
    self.selectedImage = image;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIImage *)rotateImage:(UIImage *)img {
    if (img.imageOrientation == UIImageOrientationUp)
        return img;
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [img drawInRect:(CGRect){0, 0, img.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
