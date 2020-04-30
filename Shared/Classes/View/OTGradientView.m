//
//  OTGradientView.m
//  entourage
//
//  Created by Grégoire Clermont on 04/02/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTGradientView.h"

@implementation OTGradientView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    UIColor *transparent = [UIColor.whiteColor colorWithAlphaComponent:0];
    self.backgroundColor = transparent;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)transparent.CGColor, (id)UIColor.whiteColor.CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint   = CGPointMake(1, 0);

    gradient.frame = self.bounds;
    [self.layer addSublayer:gradient];
    
    return self;
}

@end
