//
//  OTMyEntouragesViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTOptionsViewController.h"

@interface OTMyEntouragesViewController : UIViewController

@property (nonatomic, weak) id<OTOptionsDelegate> optionsDelegate;
- (void)showUnread;
@property(nonatomic) BOOL isMessagesOnly;
@property(nonatomic) BOOL isFirstLaunch;
@end
