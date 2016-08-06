//
//  OTChangeStateViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTNextStatusButtonBehavior.h"

@interface OTChangeStateViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTStatusChangedProtocol> delegate;

@end
