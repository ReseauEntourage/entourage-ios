//
//  OTPillLabelView.m
//  entourage
//
//  Created by Grégoire Clermont on 28/01/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTPillLabelView.h"
#import "OTRoleTag.h"

@interface OTPillLabelView ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation OTPillLabelView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    self.layer.cornerRadius = 4;

    return self;
}

+ (instancetype)createWithRoleTag:(OTRoleTag *)tag {
    return [self createWithRoleTag:tag andFontSize:15];
}

+ (instancetype)createWithRoleTag:(OTRoleTag *)tag andFontSize:(CGFloat)fontSize {
    OTPillLabelView *view = (OTPillLabelView*)[NSBundle.mainBundle loadNibNamed:@"OTPillLabelView" owner:nil options:nil][0];
    
    view.title = tag.title;
    view.color = tag.color;
    view.fontSize = fontSize;
    
    [view resizeToIntrinsicContentSize];

    return view;
}

- (void)setTitle:(NSString *)title {
    self.label.text = title;
}

- (NSString *)title {
    return self.label.text;
}

- (void)setColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (UIColor *)color {
    return self.backgroundColor;
}

- (void)setFontSize:(CGFloat)size {
    self.label.font = [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];

    self.topConstraint.constant      = size * 1/3.0;
    self.trailingConstraint.constant = size * 2/3.0;
    self.bottomConstraint.constant   = size * 1/3.0;
    self.leadingConstraint.constant  = size * 2/3.0;
}

- (CGFloat)fontSize {
    return self.label.font.pointSize;
}

- (CGSize)intrinsicContentSize {
    CGSize contentSize = self.label.intrinsicContentSize;
    return CGSizeMake(contentSize.width + self.leadingConstraint.constant + self.trailingConstraint.constant,
                      contentSize.height + self.topConstraint.constant + self.bottomConstraint.constant);
}

- (void)resizeToIntrinsicContentSize {
    CGSize contentSize = self.intrinsicContentSize;
    self.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
}

@end
