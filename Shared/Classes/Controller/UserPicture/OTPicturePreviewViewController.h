//
//  OTPicturePreviewViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTPicturePreviewViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) BOOL isEditingPictureForCurrentUser;

@end
