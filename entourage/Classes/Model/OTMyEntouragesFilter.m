//
//  OTMyEntouragesFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFilter.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "OTFeedItem.h"
#import "OTFeedItemTimeframeFilter.h"
#import "OTConsts.h"

#define FILTER_STATUS_KEY @"status"
#define ALL_STATUS_STRING @"all"
#define ORGANISER_KEY @"created_by_me"
#define INVITED_KEY @"accepted_invitation"

@implementation OTMyEntouragesFilter

- (instancetype)init {
    self = [super init];
    if(self) {
        self.isActive = YES;
        self.isInvited = NO;
        self.isOrganiser = NO;
        self.isClosed = YES;
        self.showDemand = YES;
        self.showContribution = YES;
        self.showTours = YES;
        self.timeframeInHours = 8 * 24;
    }
    return self;
}

- (NSArray *)groupHeaders {
    if([self.currentUser.type isEqualToString:USER_TYPE_PRO])
        return @[OTLocalizedString(@"myEntouragesTitle"), OTLocalizedString(@"filter_entourages_title")];
    else
        return @[OTLocalizedString(@"filter_entourages_title"), OTLocalizedString(@"filter_timeframe_title")];
}

- (NSArray *)toGroupedArray {
    if([self.currentUser.type isEqualToString:USER_TYPE_PRO])
        return @[
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyActive active:self.isActive],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyInvitation active:self.isInvited],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyOrganiser active:self.isOrganiser],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyClosed active:self.isClosed]
                    ],
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyDemand active:self.showDemand],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyContribution active:self.showContribution],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyTour active:self.showTours]
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

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result setObject:[self getTourTypes] forKey:FILTER_TOUR_TYPES_KEY];
    [result setObject:[self getEntourageTypes] forKey:FILTER_ENTOURAGE_TYPES_KEY];
    [result setObject:@(pageNumber) forKey:PAGE_NUMBER_KEY];
    [result setObject:@(pageSize) forKey:PAGE_SIZE_KEY];
    if(self.isOrganiser)
        [result setObject:@"true" forKey:ORGANISER_KEY];
    if(self.isInvited)
        [result setObject:@"true" forKey:INVITED_KEY];
    if([self.currentUser.type isEqualToString:USER_TYPE_PUBLIC]) {
        [result setObject:@(self.timeframeInHours) forKey:TIMEFRAME_KEY];
        [result setObject:[self getOnlyMyEntourages] forKey:FILTER_STATUS_KEY];
    }
    else
    {
        NSString *status = [self getStatus];
        if(status)
            [result setObject:[self getStatus] forKey:FILTER_STATUS_KEY];
    }
    return result;
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    switch (filter.key) {
        case FeedItemFilterKeyActive:
            self.isActive = filter.active;
            break;
        case FeedItemFilterKeyInvitation:
            self.isInvited = filter.active;
            break;
        case FeedItemFilterKeyOrganiser:
            self.isOrganiser = filter.active;
            break;
        case FeedItemFilterKeyClosed:
            self.isClosed = filter.active;
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

#pragma mark - private methods

- (NSString *)getTourTypes {
    NSArray *types = @[TOUR_MEDICAL, TOUR_SOCIAL, TOUR_DISTRIBUTIVE];
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

- (NSString *)getStatus {
    if(self.isActive)
        return self.isClosed ? ALL_STATUS_STRING : FEEDITEM_STATUS_ACTIVE;
    if(self.isClosed)
        return FEEDITEM_STATUS_CLOSED;
    return nil;
}

- (NSString *)getOnlyMyEntourages {
    return self.showOnlyMyEntourages ? FEEDITEM_STATUS_ACTIVE : ALL_STATUS_STRING;
}

@end
