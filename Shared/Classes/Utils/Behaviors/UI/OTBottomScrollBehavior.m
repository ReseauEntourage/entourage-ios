//
//  OTBottomScrollBehavior.m
//  entourage
//
//  Created by sergiu buceac on 2/16/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBottomScrollBehavior.h"

@interface OTBottomScrollBehavior ()

@property (nonatomic) CGFloat originalBottom;

@end

@implementation OTBottomScrollBehavior

- (void)initialize {
    [super initialize];
    self.originalBottom = self.bottomConstraint.constant;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)showKeyboard:(NSNotification*)notification {
    CGRect keyboardFrame = [self keyboardFrameFor:notification];
    self.bottomConstraint.constant = keyboardFrame.size.height + self.originalBottom;
    [self.table setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}

- (void)hideKeyboard:(NSNotification*)notification {
    self.bottomConstraint.constant = self.originalBottom;
}

- (CGRect)keyboardFrameFor:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    return [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end
