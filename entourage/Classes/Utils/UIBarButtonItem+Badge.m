//
//  UIBarButtonItem+Badge.m
//
//
//  Created by Veronica Gliga on 2014-05-05.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <objc/runtime.h>
#import "UIBarButtonItem+Badge.h"

NSString const *UIBarButtonItem_badgeKey = @"UIBarButtonItem_badgeKey";
NSString const *UIBarButtonItem_badgeBGColorKey = @"UIBarButtonItem_badgeBGColorKey";
NSString const *UIBarButtonItem_badgeTextColorKey = @"UIBarButtonItem_badgeTextColorKey";
NSString const *UIBarButtonItem_badgeFontKey = @"UIBarButtonItem_badgeFontKey";
NSString const *UIBarButtonItem_badgePaddingKey = @"UIBarButtonItem_badgePaddingKey";
NSString const *UIBarButtonItem_badgeMinSizeKey = @"UIBarButtonItem_badgeMinSizeKey";
NSString const *UIBarButtonItem_badgeOriginXKey = @"UIBarButtonItem_badgeOriginXKey";
NSString const *UIBarButtonItem_badgeOriginYKey = @"UIBarButtonItem_badgeOriginYKey";
NSString const *UIBarButtonItem_shouldHideBadgeAtZeroKey = @"UIBarButtonItem_shouldHideBadgeAtZeroKey";
NSString const *UIBarButtonItem_shouldAnimateBadgeKey = @"UIBarButtonItem_shouldAnimateBadgeKey";
NSString const *UIBarButtonItem_badgeValueKey = @"UIBarButtonItem_badgeValueKey";

@implementation UIBarButtonItem (Badge)

@dynamic badgeValue, badgeBGColor, badgeTextColor, badgeFont;
@dynamic badgePadding, badgeMinSize, badgeOriginX, badgeOriginY;
@dynamic shouldHideBadgeAtZero, shouldAnimateBadge;

- (void)badgeInit
{
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
    
    self.badgeBGColor   = [UIColor redColor];
    self.badgeTextColor = [UIColor whiteColor];
    self.badgeFont      = [UIFont systemFontOfSize:12.0];
    self.badgePadding   = 6;
    self.badgeMinSize   = 8;
    self.badgeOriginX   = defaultOriginX;
    self.badgeOriginY   = -4;
    self.shouldHideBadgeAtZero = YES;
    self.shouldAnimateBadge = YES;
}

#pragma mark - Utility methods

- (void)refreshBadge
{
    self.badge.textColor        = self.badgeTextColor;
    self.badge.backgroundColor  = self.badgeBGColor;
    self.badge.font             = self.badgeFont;
    
    if (!self.badgeValue || [self.badgeValue isEqualToString:@""] || ([self.badgeValue isEqualToString:@"0"] && self.shouldHideBadgeAtZero)) {
        self.badge.hidden = YES;
    } else {
        self.badge.hidden = NO;
        [self updateBadgeValueAnimated:YES];
    }
}

- (CGSize) badgeExpectedSize
{
    UILabel *frameLabel = [self duplicateLabel:self.badge];
    [frameLabel sizeToFit];
    
    CGSize expectedLabelSize = frameLabel.frame.size;
    return expectedLabelSize;
}

- (void)updateBadgeFrame
{
    CGSize expectedLabelSize = [self badgeExpectedSize];
    CGFloat minHeight = expectedLabelSize.height;
    minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = self.badgePadding;
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    self.badge.layer.masksToBounds = YES;
    self.badge.frame = CGRectMake(self.badgeOriginX, self.badgeOriginY, minWidth + padding, minHeight + padding);
    self.badge.layer.cornerRadius = (minHeight + padding) / 2;
}

- (void)updateBadgeValueAnimated:(BOOL)animated
{
    if (animated && self.shouldAnimateBadge && ![self.badge.text isEqualToString:self.badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.badge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    self.badge.text = self.badgeValue;
    if (animated && self.shouldAnimateBadge) {
        [UIView animateWithDuration:0.2 animations:^{
            [self updateBadgeFrame];
        }];
    } else {
        [self updateBadgeFrame];
    }
}

- (UILabel *)duplicateLabel:(UILabel *)labelToCopy
{
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    return duplicateLabel;
}

- (void)removeBadge
{
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
    if(lbl==nil) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.badgeOriginX, self.badgeOriginY, 20, 20)];
        [self setBadge:lbl];
        [self badgeInit];
        [self.customView addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
    }
    return lbl;
}

-(void)setBadge:(UILabel *)badgeLabel
{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeKey, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)badgeValue {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeValueKey);
}

-(void) setBadgeValue:(NSString *)badgeValue
{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeValueKey, badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBadgeValueAnimated:YES];
    [self refreshBadge];
}

-(UIColor *)badgeBGColor {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey);
}
-(void)setBadgeBGColor:(UIColor *)badgeBGColor
{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey, badgeBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

-(UIColor *)badgeTextColor {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey);
}
-(void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

-(UIFont *)badgeFont {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeFontKey);
}

-(void)setBadgeFont:(UIFont *)badgeFont
{
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeFontKey, badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

-(CGFloat) badgePadding {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgePaddingKey);
    return number.floatValue;
}

-(void) setBadgePadding:(CGFloat)badgePadding
{
    NSNumber *number = [NSNumber numberWithDouble:badgePadding];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgePaddingKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat) badgeMinSize {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey);
    return number.floatValue;
}

-(void) setBadgeMinSize:(CGFloat)badgeMinSize
{
    NSNumber *number = [NSNumber numberWithDouble:badgeMinSize];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat) badgeOriginX {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey);
    return number.floatValue;
}

-(void) setBadgeOriginX:(CGFloat)badgeOriginX
{
    NSNumber *number = [NSNumber numberWithDouble:badgeOriginX];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

-(CGFloat) badgeOriginY {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey);
    return number.floatValue;
}

-(void) setBadgeOriginY:(CGFloat)badgeOriginY
{
    NSNumber *number = [NSNumber numberWithDouble:badgeOriginY];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

-(BOOL) shouldHideBadgeAtZero {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey);
    return number.boolValue;
}

- (void)setShouldHideBadgeAtZero:(BOOL)shouldHideBadgeAtZero
{
    NSNumber *number = [NSNumber numberWithBool:shouldHideBadgeAtZero];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.badge) {
        [self refreshBadge];
    }
}

-(BOOL) shouldAnimateBadge {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey);
    return number.boolValue;
}

- (void)setShouldAnimateBadge:(BOOL)shouldAnimateBadge
{
    NSNumber *number = [NSNumber numberWithBool:shouldAnimateBadge];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.badge) {
        [self refreshBadge];
    }
}

@end
