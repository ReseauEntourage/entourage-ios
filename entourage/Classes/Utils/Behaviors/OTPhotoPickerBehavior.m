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
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        [self notifyCameraImage:info];
    else
        [self notifyGalleryImage:info];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyGalleryImage:(NSDictionary *)info {
    NSURL *imageUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    if (!imageUrl)
        imageUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    if (imageUrl)
        [self notifyPictureSelected:imageUrl];
}

- (void)notifyCameraImage:(NSDictionary *)info {
    [SVProgressHUD show];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSString *photoFilePath = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:photoFilePath];
        NSData *data = UIImageJPEGRepresentation(img, 1);
        [data writeToFile:filePath atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self notifyPictureSelected:[NSURL URLWithString:filePath]];
        });
    });
}

- (void)notifyPictureSelected:(NSURL *)pictureUrl {
    SEL selector = NSSelectorFromString(self.urlChoosenSelector);
    if ([self.parent respondsToSelector:selector])
        ((void (*)(id, SEL, NSURL *))[self.parent methodForSelector:selector])(self.parent, selector, pictureUrl);
}

@end
