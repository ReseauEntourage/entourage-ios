//
//  UITextField+indentation.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UITextField+indentation.h"

static int const kPadding = 10;

@implementation UITextField (indentation)

- (void)indent
{
    [self indentWithPadding:kPadding];
}

- (void)indentWithPadding:(CGFloat)padding
{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, padding)];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    [self setLeftView:spacerView];
}

- (void)indentRight
{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - kPadding, 0, kPadding, kPadding)];
    [self setRightViewMode:UITextFieldViewModeAlways];
    [self setRightView:spacerView];
}

- (void)setupWithPlaceholderColor:(UIColor *)color {
    NSDictionary *colorAttributes = @{ NSForegroundColorAttributeName :color};
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.placeholder
                                                              attributes:colorAttributes];
    self.attributedPlaceholder = str;
}

- (void)setupWithPlaceholderColor:(UIColor *)color andFont:(UIFont *)font {
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: color, NSFontAttributeName: font };
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.placeholder
                                                              attributes:attributes];
    self.attributedPlaceholder = str;
}

@end
