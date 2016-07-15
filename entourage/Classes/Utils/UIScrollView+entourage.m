//
//  UIScrollView+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIScrollView+entourage.h"

@implementation UIScrollView (entourage)

- (void)scrollToBottomFromKeyboardNotification:(NSNotification*)notification andHeightContraint:(NSLayoutConstraint*)constraint {

    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = self.frame;
    CGFloat keyboardOriginY = keyboardFrame.origin.y;
    constraint.constant = keyboardOriginY - viewFrame.origin.y;
    viewFrame.size.height = keyboardOriginY - viewFrame.origin.y;
    self.frame = viewFrame;
    self.contentInset = UIEdgeInsetsZero;
    [self scrollToBottom];
}

- (void)scrollToBottomFromKeyboardNotification:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = self.frame;
    CGFloat keyboardOriginY = keyboardFrame.origin.y;
    viewFrame.size.height = keyboardOriginY - viewFrame.origin.y;
    self.frame = viewFrame;
    [self scrollToBottom];
}

- (void)scrollToBottom {
    CGPoint bottomPoint = CGPointMake(0.0f, self.contentSize.height - self.bounds.size.height);
    [self setContentOffset:bottomPoint animated:YES];
}

@end
