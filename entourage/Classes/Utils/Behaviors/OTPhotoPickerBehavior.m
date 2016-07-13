//
//  OTPhotoPickerBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPhotoPickerBehavior.h"
#import "SVProgressHUD.h"

@interface OTPhotoPickerBehavior () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation OTPhotoPickerBehavior

- (void)pickFromCamera:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        [self pickPhotoFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)pickFromGallery:(UIButton *)sender {
    [self pickPhotoFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)pickPhotoFromSource:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *controller = [UIImagePickerController new];
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    controller.sourceType = sourceType;
    controller.delegate = self;
    [self.parent presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self notifyPictureSelected:img];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyPictureSelected:(UIImage *)image {
    SEL selector = NSSelectorFromString(self.urlChoosenSelector);
    if ([self.parent respondsToSelector:selector])
        ((void (*)(id, SEL, UIImage *))[self.parent methodForSelector:selector])(self.parent, selector, image);
}

@end
