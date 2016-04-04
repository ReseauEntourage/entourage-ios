//
//  UIViewController+menu.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "UIViewController+menu.h"

// Controller
#import "SWRevealViewController.h"

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
        
        menuButton = [[UIBarButtonItem alloc] init];
        [menuButton setImage:menuImage];
        [menuButton setTarget:self.revealViewController];
        [menuButton setAction:@selector(revealToggle:)];
        [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.navigationItem setRightBarButtonItem:menuButton];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    return menuButton;

}

- (UIBarButtonItem *)setupChatsButton {
    UIImage *chatsImage = [[UIImage imageNamed:@"discussion"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] init];
    [chatButton setImage:chatsImage];
    [self.navigationItem setRightBarButtonItem:chatButton];
    
    return chatButton;
}

- (void)setupCloseModal {
    UIImage *menuImage = [[UIImage imageNamed:@"close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setImage:menuImage];
    [menuButton setTarget:self];
    [menuButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
//
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (UIImage*)setupLogoImage {
    UIImage *image = [UIImage imageNamed:@"logo"];
    UIImageView *img = [[UIImageView alloc] initWithImage:image];
    img.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    img.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = img;
    return image;
}

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
