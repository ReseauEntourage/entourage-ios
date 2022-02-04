//
//  OTThemedText.h
//  entourage
//
//  Created by Grégoire Clermont on 09/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface OTThemedText : UITextView

@property (nonatomic) IBInspectable NSString *themeStyle;

@end

NS_ASSUME_NONNULL_END
