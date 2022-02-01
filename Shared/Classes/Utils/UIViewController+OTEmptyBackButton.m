//
//  UIViewController+OTEmptyBackButton.m
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "UIViewController+OTEmptyBackButton.h"
#import <objc/runtime.h>

@implementation UIViewController (OTEmptyBackButton)

+ (void)load {
    // this swizzling seems to crash IBDesignablesAgent
    #if TARGET_INTERFACE_BUILDER
    return;
    #endif

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(ot_viewDidLoad);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)ot_viewDidLoad {
    [self ot_viewDidLoad];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

}

@end
