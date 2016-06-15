//
//  OTTourFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourFactory.h"
#import "OTTourStateFactory.h"

@implementation OTTourFactory

- (id)initWithTour:(OTTour *)tour {
    self = [super init];
    if (self)
    {
        self.tour = tour;
    }
    return self;
}

- (id<OTStateFactoryDelegate>)getStateFactory {
    return [[OTTourStateFactory alloc] initWithTour:self.tour];
}

@end
