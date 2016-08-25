//
//  OTMyEntouragesViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTOptionsViewController.h"
#import "OTPendingInvitationsCHangedDelegate.h"

@interface OTMyEntouragesViewController : UIViewController<OTPendingInvitationsChangedDelegate>

@property (nonatomic, weak) id<OTOptionsDelegate> optionsDelegate;

@end
