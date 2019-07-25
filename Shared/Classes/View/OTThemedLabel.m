//
//  OTThemedLabel.m
//  entourage
//
//  Created by Grégoire Clermont on 18/04/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTThemedLabel.h"
#import "entourage-Swift.h"

@implementation OTThemedLabel

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupStyle];
    [super layoutSubviews];
}

- (void)setThemeStyle:(NSString *)themeStyle {
    _themeStyle = themeStyle;
    [self setupStyle];
}

#pragma mark - Customization

- (void)setupStyle {

    #if TARGET_INTERFACE_BUILDER
    BOOL inInterfaceBuilder = YES;
    #else
    BOOL inInterfaceBuilder = NO;
    #endif

    if (self.themeStyle == nil) {
        if (!inInterfaceBuilder) return;
        self.text = @"themeStyle must be set";
        self.textColor = UIColor.redColor;
    }
    else if ([self.themeStyle isEqualToString:@"titleColor"]) {
        self.textColor = [ApplicationTheme shared].titleLabelColor;
    }
    else if ([self.themeStyle isEqualToString:@"subtitleColor"]) {
        self.textColor = [ApplicationTheme shared].subtitleLabelColor;
    }
    else if ([self.themeStyle isEqualToString:@"Titre 3"]) {
        self.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        self.textColor = [ApplicationTheme shared].titleLabelColor;
    }
    else {
        if (!inInterfaceBuilder) return;
        self.text = [NSString stringWithFormat:@"invalid themeStyle \"%@\"", self.themeStyle];
        self.textColor = UIColor.redColor;
    }
}

@end
