//
//  OTJoinRequestedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinRequestedCell.h"
#import "OTFeedItemJoiner.h"
#import "UIButton+entourage.h"

// Sergiu : again apologies for magic numbers (i hate ios tables with autolayout)
#define BUTTON_MARGIN 144

@implementation OTJoinRequestedCell

- (void)awakeFromNib {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    CGRect bounds = CGRectMake(0, 0, self.table.contentSize.width - BUTTON_MARGIN, self.btnIgnore.bounds.size.height);
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){7.0, 7.0}].CGPath;
    self.btnIgnore.layer.mask = maskLayer;
    self.btnAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    [self.btnAvatar setupAsProfilePictureFromUrl:nil withPlaceholder:@"user"];
}

@end
