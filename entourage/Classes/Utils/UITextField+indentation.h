//
//  UITextField+indentation.h
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (indentation)

- (void)indent;
- (void)indentWithPadding:(CGFloat)padding;
- (void)indentRight;
- (void)setupWithWhitePlaceholder;

@end
