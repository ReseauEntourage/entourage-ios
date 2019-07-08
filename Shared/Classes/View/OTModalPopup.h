//
//  OTModalPopup.h
//  entourage
//
//  Created by Grégoire Clermont on 07/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OTModalPopupDelegate <NSObject>

- (void)closeModal;

@end

IB_DESIGNABLE
@interface OTModalPopup : UIStackView

@property (nonatomic, strong) id<OTModalPopupDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
