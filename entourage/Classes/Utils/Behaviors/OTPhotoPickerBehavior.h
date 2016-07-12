//
//  OTPhotoPickerBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTPhotoPickerBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *parent;
- (IBAction)pickFromGallery:(UIButton *)sender;
- (IBAction)pickFromCamera:(UIButton *)sender;

@property (nonatomic, strong) NSString *urlChoosenSelector;

@end
