//
//  OTThemedView.m
//  entourage
//
//  Created by Grégoire Clermont on 07/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTThemedView.h"
#import "entourage-Swift.h"

@implementation OTThemedView

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupColor];
    [super layoutSubviews];
}

- (void)setThemeBackgroundColor:(NSString *)themeBackgroundColor {
    _themeBackgroundColor = themeBackgroundColor;
    [self setupColor];
}

#pragma mark - Customization

- (void)setupColor {
    
#if TARGET_INTERFACE_BUILDER
    BOOL inInterfaceBuilder = YES;
#else
    BOOL inInterfaceBuilder = NO;
#endif
    
    if (self.themeBackgroundColor == nil) {
        if (!inInterfaceBuilder) return;
        self.backgroundColor = UIColor.redColor;
    }
    else if ([self.themeBackgroundColor isEqualToString:@"primary"]) {
        self.backgroundColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    }
    else if ([self.themeBackgroundColor isEqualToString:@"secondary"]) {
        self.backgroundColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    }
    else if ([self.themeBackgroundColor isEqualToString:@"neutralLight"]) {
        self.backgroundColor = [ApplicationTheme shared].subtitleLabelColor;
    }
    else {
        if (!inInterfaceBuilder) return;
        self.backgroundColor = UIColor.redColor;
    }
}

@end
