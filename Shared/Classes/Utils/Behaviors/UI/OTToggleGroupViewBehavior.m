//
//  OTToggleGroupViewBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTToggleGroupViewBehavior.h"

@interface OTToggleGroupViewBehavior ()

@property (nonatomic) CGFloat originalHeight;
@property (nonatomic) CGFloat originalMargin;

@end

@implementation OTToggleGroupViewBehavior

- (void)initialize {
    self.originalHeight = self.heightConstraint.constant;
    self.originalMargin = self.marginConstraint.constant;
}

- (void)toggle:(BOOL)visible {
    for(UIView* view in self.relatedViews)
        view.hidden = !visible;
    self.heightConstraint.constant = visible ? self.originalHeight : 0;
    self.marginConstraint.constant = visible ? self.originalMargin : 0;
}

@end
