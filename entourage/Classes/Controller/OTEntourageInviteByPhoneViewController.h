//
//  OTEntourageInviteByPhoneViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTEntourageInviteSourceViewController.h"

@interface OTEntourageInviteByPhoneViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<InviteSuccessDelegate> delegate;

@end
