//
//  OTBarButtonView.m
//  entourage
//
//  Created by veronica.gliga on 09/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBarButtonView.h"

@interface OTBarButtonView ()
{
    BOOL applied;
}
@end

@implementation OTBarButtonView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (applied || [[[UIDevice currentDevice] systemVersion] doubleValue]  < 11)
    {
        return;
    }
    
    // Find the _UIButtonBarStackView containing this view, which is a UIStackView, up to the UINavigationBar
    UIView *view = self;
    while (![view isKindOfClass:[UINavigationBar class]] && [view superview] != nil)
    {
        view = [view superview];
        if ([view isKindOfClass:[UIStackView class]] && [view superview] != nil)
        {
            if (self.position == BarButtonViewPositionLeft)
            {
                [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:view.superview
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:8.0]];
                applied = YES;
            }
            else if (self.position == BarButtonViewPositionRight)
            {
                [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:view.superview
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.0
                                                                            constant:-8.0]];
                applied = YES;
            }
            break;
        }
    }
}
@end
