//
//  OTToggleVisibleBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToggleVisibleBehavior.h"

@interface OTToggleVisibleBehavior ()

@property (nonatomic) CGFloat originalHeight;

@end

@implementation OTToggleVisibleBehavior

- (void)initialize {
    self.originalHeight = self.heightConstraint.constant;
}

- (void)toggle:(BOOL)visible animated:(BOOL)animated {
    self.heightConstraint.constant = visible ? self.originalHeight : 0;
    if(animated)
        [UIView animateWithDuration:.25 animations:^{
            [self.toggleView.superview layoutIfNeeded];
        }];
}

@end
