//
//  UIImage+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 13/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIImage+entourage.h"

@implementation UIImage (entourage)

+ (UIImage *)imageNamed:(NSString *)name withScale:(CGFloat)scale {
    
    UIImage *image = [UIImage imageNamed:name];
    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(scale, scale));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
