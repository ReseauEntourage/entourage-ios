//
//  UIBarButtonItem+entourage.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIBarButtonItem+factory.h"

@implementation UIBarButtonItem (factory)

+ (UIBarButtonItem *)createWithImageNamed:(NSString *)imageName withTarget:(id)target andAction:(SEL)action {
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *btn = [UIBarButtonItem new];
    [btn setImage:image];
    [btn setTarget:target];
    [btn setAction:action];
    return btn;
}

@end
