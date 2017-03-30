//
//  OTSolidarityGuideFiltersViewController.h
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemsFilterDelegate.h"

@interface OTSolidarityGuideFiltersViewController : UIViewController

@property (nonatomic, weak) id<OTFeedItemsFilterDelegate> filterDelegate;

@end
