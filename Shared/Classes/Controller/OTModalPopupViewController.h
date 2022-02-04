//
//  OTModalPopupViewController.h
//  entourage
//
//  Created by Grégoire Clermont on 13/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTModalPopup.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTModalPopupViewController : UIViewController

@property (strong, nonatomic) IBOutlet OTModalPopup *modal;

@end

NS_ASSUME_NONNULL_END
