//
//  OTThemedText.m
//  entourage
//
//  Created by Grégoire Clermont on 09/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTThemedText.h"
#import "entourage-Swift.h"

@implementation OTThemedText

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupTheme];
    [super layoutSubviews];
}

- (void)setThemeStyle:(NSString *)themeStyle {
    _themeStyle = themeStyle;
    [self setupTheme];
}

#pragma mark - Customization

- (void)setupTheme {
    
#if TARGET_INTERFACE_BUILDER
    BOOL inInterfaceBuilder = YES;
#else
    BOOL inInterfaceBuilder = NO;
#endif
    
    self.editable = NO;
    self.scrollEnabled = NO;
    
    if (self.themeStyle == nil) {
        if (!inInterfaceBuilder) return;
        self.text = @"themeStyle must be set";
        self.textColor = UIColor.redColor;
    }
    else if ([self.themeStyle isEqualToString:@"defaultText"]) {
        self.font = [UIFont systemFontOfSize:15];
        self.textColor = [ApplicationTheme shared].titleLabelColor;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
    }
    else if ([self.themeStyle isEqualToString:@"modalTitle"]) {
        self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
        self.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
        self.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
        self.backgroundColor = UIColor.clearColor;
    }
    else {
        if (!inInterfaceBuilder) return;
        self.text = [NSString stringWithFormat:@"invalid themeStyle \"%@\"", self.themeStyle];
        self.textColor = UIColor.redColor;
    }
}

@end
