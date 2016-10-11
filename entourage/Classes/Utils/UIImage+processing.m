//
//  UIImage+processing.m
//  entourage
//
//  Created by sergiu buceac on 10/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIImage+processing.h"

@implementation UIImage (processing)

- (UIImage *)toSquare {
    float size = MAX(self.size.width, self.size.height);
    float diff = ABS(self.size.width - self.size.height) / 2;
    float x = 0;
    float y = 0;
    if(self.size.width > self.size.height)
        y = diff;
    else
        x = diff;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 1.0);
    [self drawInRect:CGRectMake(x, y, self.size.width, self.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizeTo:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;}

@end
