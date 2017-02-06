//
//  OTScrollPinBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTScrollPinBehavior.h"

@interface OTScrollPinBehavior ()

@property (nonatomic) CGFloat originalHeight;
@property (nonatomic) BOOL initialised;
@property (nonatomic) CGFloat pinnedHeight;
@property (nonatomic) CGFloat availableHeightNoKeyboard;

@end

@implementation OTScrollPinBehavior

- (void)initialize {
    if(self.initialised)
        return;
    self.initialised = YES;
    self.originalHeight = self.scrollHeightConstraint.constant;
    self.pinnedHeight = 0;
    for(UIView *view in self.pinnedViews)
        self.pinnedHeight += view.frame.size.height;
    self.availableHeightNoKeyboard = self.owner.view.frame.size.height - self.scrollView.frame.origin.y - self.originalHeight;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)showKeyboard:(NSNotification*)notification {
    CGRect keyboardFrame = [self keyboardFrameFor:notification];
    CGFloat availableHeight = self.availableHeightNoKeyboard - keyboardFrame.size.height;
    if(availableHeight < self.pinnedHeight) {
        self.scrollHeightConstraint.constant = self.originalHeight - self.pinnedHeight + availableHeight;
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollHeightConstraint.constant) animated:YES];
        [UIView animateWithDuration:[self keyboardAnimationDurationFor:notification] animations:^{
            [self.owner.view layoutIfNeeded];
        }];
    }
}

- (void)hideKeyboard:(NSNotification*)notification {
    self.scrollHeightConstraint.constant = self.originalHeight;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:[self keyboardAnimationDurationFor:notification] animations:^{
        [self.owner.view layoutIfNeeded];
    }];
}

- (NSTimeInterval)keyboardAnimationDurationFor:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* value = [keyboardInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

- (CGRect)keyboardFrameFor:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    return [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end
