//
//  UIFont+entourage.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "UIFont+entourage.h"

@implementation UIFont (entourage)

+ (instancetype)sofiaRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Sofia-Regular" size:size];
}

+ (instancetype)calibriBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Calibri-Bold" size:size];
}

@end
