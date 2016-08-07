//
//  OTJoinRequestedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinRequestedCell.h"

@implementation OTJoinRequestedCell

- (void)awakeFromNib {
    [self.btnIgnore addObserver:self forKeyPath:@"bounds" options:0 context:nil];
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.btnIgnore && [keyPath isEqualToString:@"bounds"]) {
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.btnIgnore.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){7.0, 7.0}].CGPath;
        self.btnIgnore.layer.mask = maskLayer;
    }
}

@end
