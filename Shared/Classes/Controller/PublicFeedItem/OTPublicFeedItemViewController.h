//
//  OTPublicFeedItemViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTStatusChangedBehavior.h"

@interface OTPublicFeedItemViewController : UIViewController

@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (nonatomic, strong) OTFeedItem *feedItem;

@end
