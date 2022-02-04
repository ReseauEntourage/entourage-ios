//
//  OTThemedButton.h
//  entourage
//
//  Created by Grégoire Clermont on 11/09/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface OTThemedButton : UIButton

@property (nonatomic) IBInspectable NSString *themeColor;

@end

NS_ASSUME_NONNULL_END
