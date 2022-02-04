//
//  OTUnderlinedButton.m
//  entourage
//
//  Created by Smart Care on 24/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTUnderlinedButton.h"

@implementation OTUnderlinedButton

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}

@end
