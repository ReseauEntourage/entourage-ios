//
//  OTTourCreatorBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/30/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTTourCreatorBehaviorDelegate.h"

@interface OTTourCreatorBehavior : OTBehavior

@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, weak) id<OTTourCreatorBehaviorDelegate> delegate;

- (void)startTour:(NSString*)tourType;
- (void)stopTour;
- (void)endOngoing;

@end
