//
//  OTAutoGrowTextView.m
//  entourage
//
//  Created by sergiu buceac on 2/6/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAutoGrowTextView.h"

@interface OTAutoGrowTextView ()

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *maxHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *minHeightConstraint;

@end

@implementation OTAutoGrowTextView

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

-(void) commonInit {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            self.heightConstraint = constraint;
            break;
        }
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self handleLayoutWithAutoLayouts];
    if (self.intrinsicContentSize.height <= self.bounds.size.height) {
        CGFloat topCorrect = (self.bounds.size.height - self.contentSize.height * [self zoomScale])/2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        self.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}

-(void) handleLayoutWithAutoLayouts {
    CGSize intrinsicSize = self.intrinsicContentSize;
    if (self.minHeight)
        intrinsicSize.height = MAX(intrinsicSize.height, self.minHeight);
    if (self.maxHeight)
        intrinsicSize.height = MIN(intrinsicSize.height, self.maxHeight);
    self.heightConstraint.constant = intrinsicSize.height;
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsicContentSize = self.contentSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0f;
        intrinsicContentSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0f;
    }
    return intrinsicContentSize;
}

@end
