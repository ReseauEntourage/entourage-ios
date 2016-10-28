//
//  OTNewsFeedsSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTNewsFeedsSourceDelegate.h"

@interface OTNewsFeedsSourceBehavior : OTBehavior

@property (nonatomic, weak) id<OTNewsFeedsSourceDelegate> delegate;

- (void)updateOnFilterChange;

@end
