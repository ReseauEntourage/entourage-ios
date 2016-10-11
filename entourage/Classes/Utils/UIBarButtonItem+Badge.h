//
//  UIBarButtonItem+Badge.h
//
//
//  Created by Veronica Gliga on 2014-05-05.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Badge)

@property (strong, atomic) UILabel *badge;

@property (nonatomic) NSString *badgeValue;
@property (nonatomic) UIColor *badgeBGColor;
@property (nonatomic) UIColor *badgeTextColor;
@property (nonatomic) UIFont *badgeFont;
@property (nonatomic) CGFloat badgePadding;
@property (nonatomic) CGFloat badgeMinSize;
@property (nonatomic) CGFloat badgeOriginX;
@property (nonatomic) CGFloat badgeOriginY;
@property BOOL shouldHideBadgeAtZero;
@property BOOL shouldAnimateBadge;

@end
