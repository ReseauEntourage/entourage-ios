//
//  OTPlaceholderBackground.m
//  entourage
//
//  Created by Grégoire Clermont on 18/04/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTPlaceholderBackground.h"
#import "entourage-Swift.h"

@implementation OTPlaceholderBackground

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupView];
    [super layoutSubviews];
}

#pragma mark - Customization

-(void)setupView {
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.backgroundColor = [ApplicationTheme shared].tableViewBackgroundColor;
}

@end
