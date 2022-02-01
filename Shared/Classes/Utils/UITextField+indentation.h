//
//  UITextField+indentation.h
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (indentation)

- (void)indent;
- (void)indentWithPadding:(CGFloat)padding;
- (void)indentRight;
- (void)setupWithPlaceholderColor:(UIColor *)color;
- (void)setupWithPlaceholderColor:(UIColor *)color andFont:(UIFont *)font;

@end
