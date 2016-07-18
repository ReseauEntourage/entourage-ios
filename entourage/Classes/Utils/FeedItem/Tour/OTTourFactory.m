//
//  OTTourFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourFactory.h"
#import "OTTourStateTransition.h"
#import "OTTourStateInfo.h"
#import "OTTourMessaging.h"

@implementation OTTourFactory

- (id)initWithTour:(OTTour *)tour {
    self = [super init];
    if (self)
    {
        self.tour = tour;
    }
    return self;
}

- (id<OTStateTransitionDelegate>)getStateTransition {
    return [[OTTourStateTransition alloc] initWithTour:self.tour];
}

- (id<OTStateInfoDelegate>)getStateInfo {
    return [[OTTourStateInfo alloc] initWithTour:self.tour];
}

- (id<OTMessagingDelegate>)getMessaging {
    return [[OTTourMessaging alloc] initWithTour:self.tour];
}

@end
