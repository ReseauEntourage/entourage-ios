//
//  UIScrollView+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (entourage)

- (void)scrollToBottomFromKeyboardNotification:(NSNotification*)notification andHeightContraint:(NSLayoutConstraint*)constraint;
- (void)scrollToBottomFromKeyboardNotification:(NSNotification*)notification;
- (void)scrollToBottomFromKeyboardNotification:(NSNotification*)notification andHeightContraint:(NSLayoutConstraint*)constraint andMarker:(UIView *)control;

@end
