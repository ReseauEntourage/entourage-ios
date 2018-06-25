//
//  UIBarButtonItem+Badge.m
//
//
//  Created by Veronica Gliga on 2016-10-11.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <objc/runtime.h>
#import "UIBarButtonItem+Badge.h"

NSString const *UIBarButtonItem_badgeKey = @"UIBarButtonItem_badgeKey";
NSString const *UIBarButtonItem_badgeOriginXKey = @"UIBarButtonItem_badgeOriginXKey";
NSString const *UIBarButtonItem_badgeValueKey = @"UIBarButtonItem_badgeValueKey";
CGFloat const BadgeMinSize = 8;
CGFloat const BadgeOriginY = -4;
CGFloat const BadgePadding = 6;

@implementation UIBarButtonItem (Badge)

@dynamic badgeValue;

- (void)badgeInit {
    UIView *superview = nil;
    CGFloat defaultOriginX = 0;
    if (self.customView) {
        superview = self.customView;
        defaultOriginX = superview.frame.size.width - self.badge.frame.size.width/2;
        superview.clipsToBounds = NO;
    } else if ([self respondsToSelector:@selector(view)] && [(id)self view]) {
        superview = [(id)self view];
        defaultOriginX = superview.frame.size.width - self.badge.frame.size.width;
    }
    [superview addSubview:self.badge];
    self.badge.textColor = [UIColor whiteColor];
    self.badge.backgroundColor = [UIColor redColor];
    self.badge.font = [UIFont systemFontOfSize:12.0];
    self.badgeOriginX = defaultOriginX;
}

#pragma mark - Utility methods

- (void)refreshBadge {
    if (!self.badgeValue || [self.badgeValue isEqualToString:@""] || ([self.badgeValue isEqualToString:@"0"])) {
        self.badge.hidden = YES;
    } else {
        self.badge.hidden = NO;
        [self updateBadgeValueAnimated:YES];
    }
}

- (CGSize) badgeExpectedSize {
    UILabel *frameLabel = [self duplicateLabel:self.badge];
    [frameLabel sizeToFit];
    CGSize expectedLabelSize = frameLabel.frame.size;
    return expectedLabelSize;
}

- (void)updateBadgeFrame {
    CGSize expectedLabelSize = [self badgeExpectedSize];
    CGFloat minHeight = expectedLabelSize.height;
    minHeight = (minHeight < BadgeMinSize) ? BadgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = BadgePadding;
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    self.badge.layer.masksToBounds = YES;
    self.badge.frame = CGRectMake(self.badgeOriginX, BadgeOriginY, minWidth + padding, minHeight + padding);
    self.badge.layer.cornerRadius = (minHeight + padding) / 2;
}

- (void)updateBadgeValueAnimated:(BOOL)animated {
    if (animated  && ![self.badge.text isEqualToString:self.badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.badge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    self.badge.text = self.badgeValue;
    if (animated)
        [UIView animateWithDuration:0.2 animations:^{
            [self updateBadgeFrame];
        }];
    else
        [self updateBadgeFrame];
}

- (UILabel *)duplicateLabel:(UILabel *)labelToCopy {
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    return duplicateLabel;
}

- (void)removeBadge {
    [UIView animateWithDuration:0.2 animations:^{
        self.badge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.badge removeFromSuperview];
        self.badge = nil;
    }];
}

#pragma mark - getters/setters

-(UILabel*) badge {
    UILabel* lbl = objc_getAssociatedObject(self, &UIBarButtonItem_badgeKey);
//    if(lbl==nil) {
//        lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [self setBadge:lbl];
//        [self badgeInit];
//        [self.customView addSubview:lbl];
//        lbl.textAlignment = NSTextAlignmentCenter;
//    }
    return lbl;
}

-(void)setBadge:(UILabel *)badgeLabel {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeKey, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)badgeValue {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeValueKey);
}

-(void) setBadgeValue:(NSString *)badgeValue {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeValueKey, badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBadgeValueAnimated:YES];
    [self refreshBadge];
}

-(CGFloat) badgeOriginX {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey);
    return number.floatValue;
}

-(void) setBadgeOriginX:(CGFloat)badgeOriginX {
    NSNumber *number = [NSNumber numberWithDouble:badgeOriginX];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge)
        [self updateBadgeFrame];
}

@end
