//
//  OTToggleVisibleBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTToggleVisibleBehavior.h"

@interface OTToggleVisibleBehavior ()

@property (nonatomic) CGFloat originalHeight;
@property (nonatomic) CGFloat originalMargin;

@end

@implementation OTToggleVisibleBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    if(!self.animationDuration)
        self.animationDuration = @(0);
}

- (void)initialize {
    self.originalHeight = self.heightConstraint.constant;
    self.originalMargin = self.marginConstraint ? self.marginConstraint.constant : 0;
}

- (void)toggle:(BOOL)visible animated:(BOOL)animated {
    self.heightConstraint.constant = visible ? self.originalHeight : 0;
    self.marginConstraint.constant = visible ? self.originalMargin : 0;
    if (animated)
        [UIView animateWithDuration:self.animationDuration.doubleValue animations:^{
            [self.toggleView.superview layoutIfNeeded];
        }];
}

@end
