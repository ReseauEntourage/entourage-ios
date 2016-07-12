//
//  OTPhotoPickerBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPhotoPickerBehavior.h"

@interface OTPhotoPickerBehavior () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation OTPhotoPickerBehavior

- (void)pickFromCamera:(UIButton *)sender {
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *imageUrl = [self getImageUrlForPicker:picker withInfo:info];
    if(imageUrl)
        [self notifyPictureSelected:imageUrl];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSURL *)getImageUrlForPicker:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    NSURL *imageUrl;
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        imageUrl = [self saveImage:img];
    }
    else {
        imageUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if(!imageUrl)
            imageUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    }
    return imageUrl;
}

- (NSURL *)saveImage:(UIImage *)img {
    NSString *photoFilePath = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:photoFilePath];
    NSData *data = UIImageJPEGRepresentation(img, 1);
    [data writeToFile:filePath atomically:YES];
    return [NSURL URLWithString:filePath];
}

- (void)notifyPictureSelected:(NSURL *)pictureUrl {
    SEL selector = NSSelectorFromString(self.urlChoosenSelector);
    if([self.parent respondsToSelector:selector])
        ((void (*)(id, SEL, NSURL *))[self.parent methodForSelector:selector])(self.parent, selector, pictureUrl);
}

@end
