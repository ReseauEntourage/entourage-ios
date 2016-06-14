//
//  OTFeedItemFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemFactory.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "OTEntourageFactory.h"
#import "OTTourFactory.h"

@interface OTFeedItemFactory()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTFeedItemFactory

- (id)initWithFeedItem:(OTFeedItem *)feedItem {
    self = [super init];
    if (self)
    {
        self.feedItem = feedItem;
    }
    return self;
}

+ (id<OTFeedItemFactoryDelegate>)createFor:(OTFeedItem *)item {
    BOOL isEntourage = [item class] == [OTEntourage class];
    if(isEntourage)
        return [[OTEntourageFactory alloc] initWithEntourage:(OTEntourage *)item];
    else
        return [[OTTourFactory alloc] initWithTour:(OTTour *)item];
}

@end
