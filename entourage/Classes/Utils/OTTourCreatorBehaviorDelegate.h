//
//  OTTourCreatorDelegate.h
//  entourage
//
//  Created by sergiu buceac on 10/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTour.h"

@protocol OTTourCreatorBehaviorDelegate <NSObject>

- (void)tourStarted;
- (void)failedToStartTour;
- (void)tourDataUpdated;
- (void)flushedPointsToServer;
- (void)failedToFlushTourPointsToServer;

@end
