//
//  OTToggleVisibleWithConstraintsBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 08/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTToggleVisibleWithConstraintsBehavior.h"
#import "entourage-Swift.h"

@implementation OTToggleVisibleWithConstraintsBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.viewInvisibleConstraint.active = YES;
    self.viewVisibleConstraint.active = NO;
    self.toggledView.hidden = YES;
    
    self.toggledView.backgroundColor = [UIColor whiteColor];
    
    [self.toggledView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.toggledView.layer setShadowOpacity:0.5];
    [self.toggledView.layer setShadowRadius:4.0];
    [self.toggledView.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
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
