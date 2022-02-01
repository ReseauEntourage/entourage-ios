//
//  OTInviteByPhoneViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTInviteSourceViewController.h"

@interface OTInviteByPhoneViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<InviteSuccessDelegate> delegate;

@end
