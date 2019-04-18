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
        self.text = @"themeColor must be set";
        self.textColor = UIColor.redColor;
    }
    else if ([self.themeColor isEqualToString:@"title"]) {
        self.textColor = [ApplicationTheme shared].titleLabelColor;
    }
    else if ([self.themeColor isEqualToString:@"subtitle"]) {
        self.textColor = [ApplicationTheme shared].subtitleLabelColor;
    }
    else {
        if (!inInterfaceBuilder) return;
        self.text = [NSString stringWithFormat:@"invalid themeColor \"%@\"", self.themeColor];
        self.textColor = UIColor.redColor;
    }
}

@end
