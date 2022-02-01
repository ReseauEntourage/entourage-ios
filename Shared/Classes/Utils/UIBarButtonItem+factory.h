//
//  UIBarButtonItem+entourage.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (factory)

+ (UIBarButtonItem *)createWithImageNamed:(NSString *)imageName
                               withTarget:(id)target
                                andAction:(SEL)action;
+ (UIBarButtonItem *)createWithTitle:(NSString *)title
                          withTarget:(id)target
                           andAction:(SEL)action
                             andFont:(NSString *)font
                             colored:(UIColor *)color;
+ (UIBarButtonItem *)createWithImageNamed:(NSString *)imageName
                               withTarget:(id)target
                                andAction:(SEL)action
                          changeTintColor:(BOOL)changeTintColor;
- (void)changeEnabled:(BOOL)enabled;

@end
