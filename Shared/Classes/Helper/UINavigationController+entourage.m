//
//  UINavigationController+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 21/01/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "UINavigationController+entourage.h"

@implementation UINavigationController (entourage)

- (void)presentTransparentNavigationBar {
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UIImage new]];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    [self setNavigationBarHidden:NO animated:YES];
}

- (void)hideTransparentNavigationBar {
    [self setNavigationBarHidden:YES animated:NO];
    [self.navigationBar setBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTranslucent:[[UINavigationBar appearance] isTranslucent]];
    [self.navigationBar setShadowImage:[[UINavigationBar appearance] shadowImage]];
}

@end
