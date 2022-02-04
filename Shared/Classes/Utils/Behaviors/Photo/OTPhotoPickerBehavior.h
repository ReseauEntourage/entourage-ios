//
//  OTPhotoPickerBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTPhotoPickerBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, strong) UIImage *selectedImage;

- (IBAction)pickFromGallery:(UIButton *)sender;
- (IBAction)pickFromCamera:(UIButton *)sender;

@end
