//
//  OTFeedItemFiltersViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemsFilterDelegate.h"

@interface OTFeedItemFiltersViewController : UIViewController

@property (nonatomic, weak) id<OTFeedItemsFilterDelegate> filterDelegate;

@end
