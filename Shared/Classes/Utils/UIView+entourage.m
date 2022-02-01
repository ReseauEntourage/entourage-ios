//
//  UIView+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "UIView+entourage.h"

static const CGFloat kRadius = 4.f;

@implementation UIView (entourage)

- (void)setupRoundedCorners {
    self.layer.cornerRadius = kRadius;
}

- (void)showRedBorders {
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor redColor].CGColor;
}

@end
