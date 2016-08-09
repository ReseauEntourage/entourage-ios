//
//  OTMoveUpOnViewHiddenBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMoveUpOnViewHiddenBehavior.h"

@interface OTMoveUpOnViewHiddenBehavior ()

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic) CGFloat originalHeight;

@end

@implementation OTMoveUpOnViewHiddenBehavior

- (void)initialize {
    for(NSLayoutConstraint *constraint in self.toggleView.constraints)
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            self.heightConstraint = constraint;
            self.originalHeight = self.heightConstraint.constant;
            break;
        }
    if(!self.heightConstraint)
        @throw @"View must have a height constraint.";
}

- (void)toggle:(BOOL)visible animated:(BOOL)animated {
    self.heightConstraint.constant = visible ? self.originalHeight : 0;
    if(animated)
        [UIView animateWithDuration:.25 animations:^{
            [self.toggleView.superview layoutIfNeeded];
        }];
}

@end
