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
#import "OTAnnouncement.h"
#import "OTAnnouncementFactory.h"

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
    BOOL isAnnouncement = [item class] == [OTAnnouncement class];
    BOOL isTour = [item class] == [OTTour class];
   
    if (isEntourage) {
        return [[OTEntourageFactory alloc] initWithEntourage:(OTEntourage *)item];
    }
    else if (isAnnouncement) {
        return [[OTAnnouncementFactory alloc] initWithAnnouncement:(OTAnnouncement *)item];
    }
    else if (isTour) {
        return [[OTTourFactory alloc] initWithTour:(OTTour *)item];
    }
    
    return nil;
}

+ (id<OTFeedItemFactoryDelegate>)createForType:(NSString *)feedItemType
                                         andId:(NSNumber *)feedItemId {
    BOOL isTour = [feedItemType isEqualToString:TOUR_TYPE_NAME];
    if (isTour) {
        OTTour *tour = [OTTour new];
        tour.uid = feedItemId;
        return [[OTTourFactory alloc] initWithTour:tour];
    }
    else {
        OTEntourage *entourage = [OTEntourage new];
        entourage.uid = feedItemId;
        return [[OTEntourageFactory alloc] initWithEntourage:entourage];
    }
}

+ (id<OTFeedItemFactoryDelegate>)createEntourageForGroupType:(NSString *)groupType
                                         andId:(NSNumber *)feedItemId {
    OTEntourage *entourage = [OTEntourage new];
    entourage.uid = feedItemId;
    entourage.groupType = groupType;
    return [[OTEntourageFactory alloc] initWithEntourage:entourage];
}

+ (id<OTFeedItemFactoryDelegate>)createForId:(NSString *)feedItemId {
        OTEntourage *entourage = [OTEntourage new];
        entourage.fid = feedItemId;
        return [[OTEntourageFactory alloc] initWithEntourage:entourage];
}

@end
