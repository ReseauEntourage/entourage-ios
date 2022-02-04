//
//  OTPillLabelView.h
//  entourage
//
//  Created by Grégoire Clermont on 28/01/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRoleTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTPillLabelView : UIView

@property NSString *title;
@property UIColor *color;
@property CGFloat fontSize;

+ (OTPillLabelView *)createWithRoleTag:(OTRoleTag *)tag;
+ (OTPillLabelView *)createWithRoleTag:(OTRoleTag *)tag andFontSize:(CGFloat)fontSize;

- (void)resizeToIntrinsicContentSize;

@end

NS_ASSUME_NONNULL_END
