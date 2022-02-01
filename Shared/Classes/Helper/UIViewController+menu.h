//
//  UIViewController+menu.h
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (menu)

/**************************************************************************************************/
#pragma mark - Configure

- (UIBarButtonItem *)setupChatsButtonWithTarget:(id)target andSelector:(SEL)selector;
- (UIBarButtonItem *)setupCloseModal;
- (UIBarButtonItem*)setupCloseModalWithoutTintWithTint:(UIColor*)tintColor;
- (UIBarButtonItem*)setupCloseModalWithTintColor;
- (UIBarButtonItem *)setupCloseModalTransparent;
- (void)setupLogoImageWithTarget:(id)target andSelector:(SEL)action;
- (UIBarButtonItem *)setupCloseModalWithTarget:(id)target andSelector:(SEL)action;
- (UIBarButtonItem *)setupCloseModalWithTintColorAndTarget:(id)target andSelector:(SEL)action;

@end
