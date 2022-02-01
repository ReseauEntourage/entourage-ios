//
//  OTStartTourAnnotationView.m
//  entourage
//
//  Created by sergiu buceac on 11/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTStartTourAnnotationView.h"
#import "OTStartTourAnnotation.h"

#define LabelPaddings 6.0
#define LabelCornerRadius 4.0
#define LabelFontSize 10.0
#define TriangleSize CGSizeMake(15, 21)

@interface OTStartTourAnnotationView ()

@property (nonatomic, strong) UILabel *lblData;
@property (nonatomic, strong) UIView *triangleView;

@end

@implementation OTStartTourAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        self.lblData = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblData.textAlignment = NSTextAlignmentCenter;
        self.lblData.font = [UIFont fontWithName:@"SFUIText-Medium" size:LabelFontSize];
        self.lblData.backgroundColor = [UIColor whiteColor];
        self.lblData.layer.cornerRadius = LabelCornerRadius;
        self.lblData.clipsToBounds = YES;
        [self addSubview:self.lblData];
        
        self.triangleView = [[UIView alloc] initWithFrame:CGRectZero];
        self.triangleView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.triangleView];
        
        UIBezierPath *maskPath = [UIBezierPath new];
        [maskPath moveToPoint:(CGPoint){TriangleSize.width / 4, TriangleSize.height / 4}];
        [maskPath addLineToPoint:(CGPoint){TriangleSize.width / 2, 0}];
        [maskPath addLineToPoint:(CGPoint){TriangleSize.width, TriangleSize.height}];
        [maskPath addLineToPoint:(CGPoint){0, TriangleSize.height / 2}];
        [maskPath closePath];
        CAShapeLayer *mask = [CAShapeLayer new];
        mask.frame = self.triangleView.bounds;
        mask.path = maskPath.CGPath;
        self.triangleView.layer.mask = mask;
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    self.lblData.text = ((OTStartTourAnnotation *)annotation).tour.organizationName;
    [self updateFrames];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrames];
}

#pragma mark - private methods

- (void)updateFrames {
    if(!self.lblData)
        return;
    
    CGSize textSize = [self.lblData.text sizeWithAttributes:@{NSFontAttributeName:self.lblData.font}];
    CGRect lblFrame = CGRectMake(0, 0, textSize.width + 2 * LabelPaddings, textSize.height + 2 * LabelPaddings);
    lblFrame.origin = CGPointMake(-lblFrame.size.width - TriangleSize.width / 2, -lblFrame.size.height - TriangleSize.height / 2);
    self.lblData.frame = lblFrame;
    
    CGRect triangleFrame = CGRectZero;
    triangleFrame.size = TriangleSize;
    triangleFrame.origin = CGPointMake(-TriangleSize.width, -TriangleSize.height);
    self.triangleView.frame = triangleFrame;
}

@end
