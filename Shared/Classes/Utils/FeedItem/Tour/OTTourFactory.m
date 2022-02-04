//
//  OTTourFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTTourFactory.h"
#import "OTTourStateTransition.h"
#import "OTTourStateInfo.h"
#import "OTTourMessaging.h"
#import "OTTourUI.h"
#import "OTTourMapHandler.h"
#import "OTTourJoinerDelegate.h"
#import "OTTourChangedHandler.h"

@implementation OTTourFactory

- (id)initWithTour:(OTTour *)tour {
    self = [super init];
    if (self)
    {
        self.tour = tour;
    }
    return self;
}

- (BOOL)isTour {
    return YES;
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

- (id<OTUIDelegate>)getUI {
    return [[OTTourUI alloc] initWithTour:self.tour];
}

- (id<OTMapHandlerDelegate>)getMapHandler {
    return [[OTTourMapHandler alloc] initWithTour:self.tour];
}

- (id<OTJoinerDelegate>)getJoiner {
    return [[OTTourJoinerDelegate alloc] initWithTour:self.tour];
}

- (id<OTChangedHandlerDelegate>)getChangedHandler {
    return [[OTTourChangedHandler alloc] initWithTour:self.tour];
}

@end
