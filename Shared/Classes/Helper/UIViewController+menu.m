//
//  UIViewController+menu.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import "UIViewController+menu.h"
#import "UIBarButtonItem+Badge.h"
#import "OTUnreadMessagesService.h"
#import "OTConsts.h"
#import "entourage-Swift.h"

@implementation UIViewController (menu)

/**************************************************************************************************/
#pragma mark - Configure

- (UIBarButtonItem *)setupChatsButtonWithTarget:(id)target andSelector:(SEL)selector {
    UIImage *chatsImage = [[UIImage imageNamed:@"discussion"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,chatsImage.size.width, chatsImage.size.height);
    [button setBackgroundImage:chatsImage forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:chatButton];
    self.navigationItem.rightBarButtonItem.badgeValue = [OTUnreadMessagesService sharedInstance].totalCount.stringValue;
    return chatButton;
}

- (UIBarButtonItem*)setupCloseModalWithImageNamed:(NSString *)imageName applyTintColor:(BOOL)useTintColor {
    if (useTintColor) {        
        UIImage *menuImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
        menuButton.image = menuImage;
        menuButton.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
        [menuButton setTarget:self];
        [menuButton setAction:@selector(dismissModal)];
        
        [self.navigationItem setLeftBarButtonItem:menuButton];
        self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
        
        return  menuButton;
    }
    
    return  [self setupCloseModalWithImageNamed:imageName];
}

- (UIBarButtonItem*)setupCloseModalWithImageNamed:(NSString *)imageName {
    UIImage *menuImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    menuButton.image = menuImage;
    menuButton.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [menuButton setTarget:self];
    [menuButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    
    return  menuButton;
}
- (UIBarButtonItem*)setupCloseModalWithImageNamedOnly:(NSString *)imageName withTint:(UIColor*)tintColor {
    UIImage *menuImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    menuButton.image = menuImage;
    menuButton.tintColor = tintColor;
    [menuButton setTarget:self];
    [menuButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
    
    return  menuButton;
}

- (UIBarButtonItem*)setupCloseModal {
    return [self setupCloseModalWithImageNamed:@"close" applyTintColor:YES];
}

- (UIBarButtonItem*)setupCloseModalWithoutTintWithTint:(UIColor*)tintColor {
    
    return [self setupCloseModalWithImageNamedOnly:@"close" withTint:tintColor];
}

- (UIBarButtonItem*)setupCloseModalWithTintColor {
    return [self setupCloseModalWithImageNamed:@"close" applyTintColor:YES];
}

- (UIBarButtonItem *)setupCloseModalWithTarget:(id)target andSelector:(SEL)action {
    return [self setupCloseModalWithImageNamed:@"close" target:target andSelector:action];
}

- (UIBarButtonItem *)setupCloseModalWithTintColorAndTarget:(id)target andSelector:(SEL)action {
    return [self setupCloseModalWithTitnColorAndImageNamed:@"close" target:target andSelector:action];
}

- (UIBarButtonItem *)setupCloseModalTransparent {
    return [self setupCloseModalWithImageNamed:@"whiteClose"];
}

- (void)setupLogoImageWithTarget:(id)target andSelector:(SEL)action {
    UIImage *image = [OTAppAppearance applicationLogo];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
}

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIBarButtonItem *)setupCloseModalWithImageNamed:(NSString *)imageName
                                            target:(id)target
                                       andSelector:(SEL)action {
    UIBarButtonItem *menuButton = [self setupCloseModalWithImageNamed:imageName];
    [menuButton setTarget:target];
    [menuButton setAction:action];
    return  menuButton;
}

- (UIBarButtonItem *)setupCloseModalWithTitnColorAndImageNamed:(NSString *)imageName
                                            target:(id)target
                                       andSelector:(SEL)action {
    UIBarButtonItem *menuButton = [self setupCloseModalWithImageNamed:imageName applyTintColor:YES];
    [menuButton setTarget:target];
    [menuButton setAction:action];
    return  menuButton;
}

@end
