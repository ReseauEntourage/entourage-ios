//
//  OTCustomSegmentedBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 04/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCustomSegmentedBehavior.h"

@interface OTCustomSegmentedBehavior ()

@property (nonatomic, assign) int selectedButton;

@end

@implementation OTCustomSegmentedBehavior

- (void)initialize {
    [super initialize];
    //self.selectedIndex = 0;
}

- (int)selectedIndex {
    return self.selectedButton;
}

- (void)setSelectedIndex:(int)selectedIndex {
    self.selectedButton = selectedIndex;
    for(int i = 0; i < self.segments.count; i++)
        [self.segments[i] setSelected:i == self.selectedButton];
}

- (void)updateVisible:(BOOL)visible {
    self.segmentedControl.hidden = !visible;
}

- (void)segmentTapped:(id)sender {
    for(int i = 0; i < self.segments.count; i++) {
        UIButton *btn = self.segments[i];
        btn.selected = btn == sender;
        if(btn.selected) {
            self.selectedButton = i;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

@end
