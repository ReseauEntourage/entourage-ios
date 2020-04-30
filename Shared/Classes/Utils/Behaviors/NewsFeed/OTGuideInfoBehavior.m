//
//  OTGuideInfoBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 19/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTGuideInfoBehavior.h"
#import "entourage-Swift.h"

@implementation OTGuideInfoBehavior

static bool infoClosed = NO;

- (void)closePopup:(id)sender {
    infoClosed = YES;
    [self toggleInfoOpen:NO];
}

- (void)show {
    if(infoClosed)
        return;
    [self toggleInfoOpen:YES];
}

- (void)hide {
    [self toggleInfoOpen:NO];
}

#pragma mark - private methods

- (void)toggleInfoOpen:(BOOL)open {
    self.infoPopup.backgroundColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    self.infoPopup.hidden = !open;
}

@end
