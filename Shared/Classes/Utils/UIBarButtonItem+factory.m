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

+ (UIBarButtonItem *)createWithTitle:(NSString *)title
                          withTarget:(id)target
                           andAction:(SEL)action
                             andFont:(NSString *)font
                             colored:(UIColor *)color {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:title
                                                            style:UIBarButtonItemStyleDone
                                                           target:target
                                                           action:action];
    
    [btn changeFont:font andColor:color];
    return btn;
}

- (void)changeEnabled:(BOOL)enabled {
    self.enabled = enabled;
    CGFloat alpha = enabled ? 1 : 0.3;
    UIColor* newColor = [self.tintColor colorWithAlphaComponent:alpha];
    [self changeColor:newColor];
}

- (void)changeColor:(UIColor *)color {
    [self setTintColor:color];
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: color, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

- (void)changeFont:(NSString *)font
          andColor:(UIColor *)color {
    [self setTitleTextAttributes:@{
                                   NSFontAttributeName: [UIFont fontWithName:font size:17],
                                   NSForegroundColorAttributeName: color
                                   }
                        forState:UIControlStateNormal];
}

@end
