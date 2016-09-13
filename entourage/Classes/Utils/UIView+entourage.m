//
//  UIView+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIView+entourage.h"

static const CGFloat kRadius = 4.f;

@implementation UIView (entourage)

- (void)setupRoundedCorners {
    self.layer.cornerRadius = kRadius;
}

- (void)setupHalfRoundedCorners {
    self.layer.cornerRadius = self.bounds.size.height/2.0f;
}

- (void)showRedBorders {
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor redColor].CGColor;
}

@end
