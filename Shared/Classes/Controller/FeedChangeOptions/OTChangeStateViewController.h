//
//  OTChangeStateViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTNextStatusButtonBehavior.h"
#import "OTEditEntourageBehavior.h"
#import "OTInviteSourceViewController.h"

@interface OTChangeStateViewController : UIViewController <InviteSourceDelegate>

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTEditEntourageBehavior *editEntourageBehavior;
@property (nonatomic, weak) id<OTStatusChangedProtocol> delegate;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *buttonsWithBorder;
@property (nonatomic) BOOL shouldShowTabBarOnClose;

@end
