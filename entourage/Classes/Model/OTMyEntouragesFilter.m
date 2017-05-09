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
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"

#define ALL_STATUS_STRING @"all"

@implementation OTMyEntouragesFilter

- (instancetype)init {
    self = [super init];
    if(self) {
        self.isUnread = NO;
        self.isIncludingClosed = YES;
        self.showDemand = YES;
        self.showContribution = YES;
        self.showTours = YES;
    }
    return self;
}

- (NSArray *)groupHeaders {
    if(IS_PRO_USER)
        return @[OTLocalizedString(@"myEntouragesTitle"), OTLocalizedString(@"filter_entourages_title")];
    else
        return @[OTLocalizedString(@"filter_entourages_title"), OTLocalizedString(@"filter_timeframe_title")];
}

- (NSArray *)toGroupedArray {
    if(IS_PRO_USER)
        return @[
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyUnread active:self.isUnread],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed active:self.isIncludingClosed]
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
                        [OTFeedItemFilter createFor:FeedItemFilterKeyUnread active:self.isUnread],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed active:self.isIncludingClosed]
                     ],
                    @[
                        [OTFeedItemFilter createFor:FeedItemFilterKeyDemand active:self.showDemand],
                        [OTFeedItemFilter createFor:FeedItemFilterKeyContribution active:self.showContribution],
                     ]
                ];
}

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result setObject:[self getTourTypes] forKey:@"tour_types"];
    [result setObject:[self getEntourageTypes] forKey:@"entourage_types"];
    [result setObject:@(pageNumber) forKey:@"page"];
    [result setObject:@(pageSize) forKey:@"per"];
    if(self.isUnread)
        [result setObject:@"true" forKey:@"created_by_me"];
    NSString *status = [self getStatus];
    if(status)
        [result setObject:[self getStatus] forKey:@"status"];
    return result;
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    switch (filter.key) {
        case FeedItemFilterKeyUnread:
            self.isUnread = filter.active;
            break;
        case FeedItemFilterKeyIncludingClosed:
            self.isIncludingClosed = filter.active;
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
        default:
            break;
    }
}

#pragma mark - private methods

- (NSString *)getTourTypes {
    NSArray *types = @[TOUR_MEDICAL, TOUR_SOCIAL, TOUR_DISTRIBUTIVE];
    if(self.showTours && IS_PRO_USER)
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
    return self.isIncludingClosed ? ALL_STATUS_STRING : FEEDITEM_STATUS_ACTIVE;
}

@end
