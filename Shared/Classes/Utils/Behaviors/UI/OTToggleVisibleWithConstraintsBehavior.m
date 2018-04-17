//
//  OTToggleVisibleWithConstraintsBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 08/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTToggleVisibleWithConstraintsBehavior.h"

@implementation OTToggleVisibleWithConstraintsBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.viewInvisibleConstraint.active = YES;
    self.viewVisibleConstraint.active = NO;
    self.toggledView.hidden = YES;
}

- (void)toggle:(BOOL)visible {
    if(visible) {
        self.viewVisibleConstraint.active = YES;
        self.viewInvisibleConstraint.active = NO;
    }
    else {
        self.viewInvisibleConstraint.active = YES;
        self.viewVisibleConstraint.active = NO;
    }
    self.toggledView.hidden = !visible;
}

@end
