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
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame;

+ (UIImage *)imageFromView:(UIView *)theView withSize:(CGSize)size;
+ (UIImage *)blurredImageInView:(UIView *)view withRadius:(CGFloat)radius;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIImage *) getImageWithUnsaturatedPixelsOfImage:(UIImage *)image;
+ (UIImage *) getImageWithTintedColor:(UIImage *)image withTint:(UIColor *)color withIntensity:(float)alpha;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

@end
