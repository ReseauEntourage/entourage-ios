//
//  UIBarButtonItem+entourage.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (factory)

+ (UIBarButtonItem *)createWithImageNamed:(NSString *)imageName withTarget:(id)target andAction:(SEL)action;

@end
