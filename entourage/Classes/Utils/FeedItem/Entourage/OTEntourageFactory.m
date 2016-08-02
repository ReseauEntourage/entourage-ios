//
//  OTEntourageFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageFactory.h"
#import "OTEntourageStateTransition.h"
#import "OTEntourageStateInfo.h"
#import "OTEntourageMessaging.h"
#import "OTEntourageUI.h"

@implementation OTEntourageFactory

- (id)initWithEntourage:(OTEntourage *)entourage {
    self = [super init];
    if (self)
    {
        self.entourage = entourage;
    }
    return self;
}

- (id<OTStateTransitionDelegate>)getStateTransition {
    return [[OTEntourageStateTransition alloc] initWithEntourage:self.entourage];
}

- (id<OTStateInfoDelegate>)getStateInfo {
    return [[OTEntourageStateInfo alloc] initWithEntourage:self.entourage];
}

- (id<OTMessagingDelegate>)getMessaging {
    return [[OTEntourageMessaging alloc] initWithEntourage:self.entourage];
}

- (id<OTUIDelegate>)getUI {
    return [[OTEntourageUI alloc] initWithEntourage:self.entourage];
}

@end
