//
//  UIImage+processing.h
//  entourage
//
//  Created by sergiu buceac on 10/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (processing)

- (UIImage *)toSquare;
- (UIImage *)resizeTo:(CGSize)size;

@end
