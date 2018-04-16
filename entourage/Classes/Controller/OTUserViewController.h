//
//  OTUserViewController.h
//  entourage
//
//  Created by Nicolas Telera on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
// Model
#import "OTUser.h"
@class OTPopupViewController;

@interface OTUserViewController : UIViewController

@property (nonatomic, strong) OTUser *user;
@property (nonatomic, strong) NSNumber *userId;

@end
