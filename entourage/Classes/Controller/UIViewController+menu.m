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
- (UIBarButtonItem *)createMenuButton
{
    UIBarButtonItem *menuButton = nil;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        UIImage *menuImage = [[UIImage imageNamed:@"ic_menu.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
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
        UIImage *menuImage = [[UIImage imageNamed:@"backFront.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
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

@end
