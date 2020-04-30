//
//  OTThemedButton.m
//  entourage
//
//  Created by Grégoire Clermont on 11/09/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTThemedButton.h"
#import "entourage-Swift.h"

@implementation OTThemedButton

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupColor];
    [super layoutSubviews];
}

- (void)setThemeColor:(NSString *)themeColor {
    _themeColor = themeColor;
    [self setupColor];
}

#pragma mark - Customization

- (void)setupColor {
    
    #if TARGET_INTERFACE_BUILDER
    BOOL inInterfaceBuilder = YES;
    #else
    BOOL inInterfaceBuilder = NO;
    #endif
    
    if (self.themeColor == nil) {
        if (!inInterfaceBuilder) return;
        [self setTitle:@"themeColor must be set" forState:UIControlStateNormal];
        self.tintColor = UIColor.redColor;
    }
    else if ([self.themeColor isEqualToString:@"appPrimaryColor"]) {
        self.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    }
    else {
        if (!inInterfaceBuilder) return;
        [self setTitle:[NSString stringWithFormat:@"invalid themeColor \"%@\"", self.themeColor]
              forState:UIControlStateNormal];
        self.tintColor = UIColor.redColor;
    }
}

@end
