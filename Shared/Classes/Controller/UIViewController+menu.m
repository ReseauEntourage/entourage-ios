//
//  UIViewController+menu.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "UIViewController+menu.h"
#import "UIBarButtonItem+Badge.h"
#import "OTUnreadMessagesService.h"
#import "OTConsts.h"
#import "SWRevealViewController.h"
#import "entourage-Swift.h"

@implementation UIViewController (menu)

/**************************************************************************************************/
#pragma mark - Configure

/**
 * Method which creates the MenuButton in navigation bar at left position
 *
 * @return UIBarButtonItem
 * The MenuButton instanciated
 */

- (UIBarButtonItem *)createMenuButton {
    UIBarButtonItem *menuButton = nil;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        UIImage *menuImage = [[UIImage imageNamed:@"menu.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        menuButton = [[UIBarButtonItem alloc] init];
        [menuButton setImage:menuImage];
        [menuButton setTarget:self.revealViewController];
        [menuButton setAction:@selector(revealToggle:)];
        [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.navigationItem setLeftBarButtonItem:menuButton];
    }
    
    return menuButton;
}

- (UIBarButtonItem *)createBackFrontMenuButton {
    UIBarButtonItem *menuButton = nil;
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        UIImage *menuImage = [[UIImage imageNamed:@"backArrow.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

         UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
         [back setImage:menuImage
               forState:UIControlStateNormal];
         [back addTarget:self.revealViewController
                  action:@selector(revealToggle:)
        forControlEvents:UIControlEventTouchUpInside];
         [back setFrame:CGRectMake(0, 0, 20, 20)];
         menuButton = [[UIBarButtonItem alloc] initWithCustomView:back];
        
        [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.navigationItem setRightBarButtonItem:menuButton];
        
        self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    }
    return menuButton;
}

- (UIBarButtonItem *)setupChatsButtonWithTarget:(id)target andSelector:(SEL)selector {
    UIImage *chatsImage = [[UIImage imageNamed:@"discussion"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
        self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
        
        return  menuButton;
    }
    
    return  [self setupCloseModalWithImageNamed:imageName];
}

- (UIBarButtonItem*)setupCloseModalWithImageNamed:(NSString *)imageName {
    UIImage *menuImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    menuButton.image = menuImage;
    [menuButton setTarget:self];
    [menuButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    
    return  menuButton;
}

- (UIBarButtonItem*)setupCloseModal {
    return [self setupCloseModalWithImageNamed:@"close.png"];
}

- (UIBarButtonItem*)setupCloseModalWithTintColor {
    return [self setupCloseModalWithImageNamed:@"close.png" applyTintColor:YES];
}

- (UIBarButtonItem *)setupCloseModalWithTarget:(id)target andSelector:(SEL)action {
    return [self setupCloseModalWithImageNamed:@"close.png" target:target andSelector:action];
}

- (UIBarButtonItem *)setupCloseModalWithTintColorAndTarget:(id)target andSelector:(SEL)action {
    return [self setupCloseModalWithTitnColorAndImageNamed:@"close.png" target:target andSelector:action];
}

- (UIBarButtonItem *)setupCloseModalTransparent {
    return [self setupCloseModalWithImageNamed:@"whiteClose.png"];
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
