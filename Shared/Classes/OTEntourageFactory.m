//
//  OTEntourageFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTEntourageFactory.h"
#import "OTEntourageStateFactory.h"

@implementation OTEntourageFactory

- (id)initWithEntourage:(OTEntourage *)entourage {
    self = [super init];
    if (self)
    {
        self.entourage = entourage;
    }
    return self;
}

- (id<OTStateFactoryDelegate>)getStateFactory {
    return [[OTEntourageStateFactory alloc] initWithEntourage:self.entourage];
}

@end
