//
//  OTNewsFeedsFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedsFilter.h"
#import "OTConsts.h"
#import "OTFeedItemFilter.h"
#import "OTFeedItemTimeframeFilter.h"
#import "OTTour.h"
#import "OTEntourage.h"

#define FEEDS_REQUEST_DISTANCE_KM 10

@implementation OTNewsFeedsFilter

- (instancetype)init {
    self = [super init];
    if(self) {
        BOOL isPro = [self.currentUser.type isEqualToString:USER_TYPE_PRO];
        self.showMedical = isPro;
        self.showSocial = isPro;
        self.showDistributive = isPro;
        self.showDemand = !isPro;
        self.showContribution = !isPro;
        self.showTours = isPro;
        self.showOnlyMyEntourages = NO;
        self.timeframeInHours = 8 * 24;
    }
    return self;
}

- (NSArray *)groupHeaders {
    if([self.currentUser.type isEqualToString:USER_TYPE_PRO])
        return @[OTLocalizedString(@"filter_maraudes_title"), OTLocalizedString(@"filter_entourages_title"), OTLocalizedString(@"filter_timeframe_title")];
    else
        return @[OTLocalizedString(@"filter_entourages_title"), OTLocalizedString(@"filter_timeframe_title")];
}

- (NSArray *)toGroupedArray {
    if([self.currentUser.type isEqualToString:USER_TYPE_PRO])
        return @[
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyMedical active:self.showMedical withImage:@"filter_heal"],
                        [OTFeedItemFilter createFor:FeedItemFilterKeySocial active:self.showSocial withImage:@"filter_social"],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyDistributive active:self.showDistributive withImage:@"filter_eat"]
                    ],
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyDemand active:self.showDemand],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyContribution active:self.showContribution],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyTour active:self.showTours],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyOnlyMyEntourages active:self.showOnlyMyEntourages]
                    ],
                    @[
                        [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe timeframeInHours:self.timeframeInHours]
                    ]
                ];
    else
        return @[
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyDemand active:self.showDemand],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyContribution active:self.showContribution],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyOnlyMyEntourages active:self.showOnlyMyEntourages]
                    ],
                    @[
                        [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe timeframeInHours:self.timeframeInHours]
                    ]
                ];
}

- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before andLocation:(CLLocationCoordinate2D)location {
    return [NSMutableDictionary dictionaryWithDictionary: @{
        @"before" : before,
        @"latitude": @(location.latitude),
        @"longitude": @(location.longitude),
        @"distance": @FEEDS_REQUEST_DISTANCE_KM,
        @"tour_types": [self getTourTypes],
        @"entourage_types": [self getEntourageTypes],
        @"show_tours": self.showTours ? @"true" : @"false",
        @"show_my_entourages_only" : self.showOnlyMyEntourages ? @"true" : @"false",
        @"time_range" : @(self.timeframeInHours)
    }];
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    switch (filter.key) {
        case FeedItemFilterKeyMedical:
            self.showMedical = filter.active;
            break;
        case FeedItemFilterKeySocial:
            self.showSocial = filter.active;
            break;
        case FeedItemFilterKeyDistributive:
            self.showDistributive = filter.active;
            break;
        case FeedItemFilterKeyDemand:
            self.showDemand = filter.active;
            break;
        case FeedItemFilterKeyContribution:
            self.showContribution = filter.active;
            break;
        case FeedItemFilterKeyTour:
            self.showTours = filter.active;
            break;
        case FeedItemFilterKeyOnlyMyEntourages:
            self.showOnlyMyEntourages = filter.active;
            break;
        case FeedItemFilterKeyTimeframe:
            self.timeframeInHours = ((OTFeedItemTimeframeFilter *)filter).timeframeInHours;
            break;
        default:
            break;
    }
}

- (NSArray *)timeframes {
    return @[@(24), @(8*24), @(30*24)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d|%d|%d|%d|%d|%d|%d|%d|%f|%f", self.showMedical, self.showSocial, self.showDistributive, self.showDemand, self.showContribution, self.showTours, self.showOnlyMyEntourages, self.timeframeInHours, self.location.latitude, self.location.longitude];
}

- (NSString *)getTourTypes {
    NSMutableArray *types = [NSMutableArray new];
    if(self.showMedical)
        [types addObject:OTLocalizedString(@"tour_type_medical")];
    if(self.showSocial)
        [types addObject:OTLocalizedString(@"tour_type_bare_hands")];
    if(self.showDistributive)
        [types addObject:OTLocalizedString(@"tour_type_alimentary")];
    if(self.showTours && [self.currentUser.type isEqualToString:USER_TYPE_PRO])
        return [types componentsJoinedByString:@","];
    return @"";
}

- (NSString *)getEntourageTypes {
    NSMutableArray *types = [NSMutableArray new];
    if(self.showDemand)
        [types addObject:ENTOURAGE_DEMANDE];
    if(self.showContribution)
        [types addObject:ENTOURAGE_CONTRIBUTION];
    return [types componentsJoinedByString:@","];
}

- (id)copyWithZone:(NSZone *)zone {
    OTNewsFeedsFilter *copy = [OTNewsFeedsFilter new];
    copy.showMedical = self.showMedical;
    copy.showSocial = self.showSocial;
    copy.showDistributive = self.showDistributive;
    copy.showDemand = self.showDemand;
    copy.showContribution = self.showContribution;
    copy.showTours = self.showTours;
    copy.showOnlyMyEntourages = self.showOnlyMyEntourages;
    copy.timeframeInHours = self.timeframeInHours;
    copy.location = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    return copy;
}

@end
