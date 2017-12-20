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
#import "OTSavedMyEntouragesFilter.h"

#define ALL_STATUS_STRING @"all"

@implementation OTMyEntouragesFilter

- (instancetype)init {
    self = [super init];
    if(self) {
        OTSavedMyEntouragesFilter *savedFilter = [NSUserDefaults standardUserDefaults].savedMyEntouragesFilter;
        if (savedFilter) {
            self.showTours = savedFilter.showTours.boolValue;
            self.showDemand = savedFilter.showDemand.boolValue;
            self.showContribution = savedFilter.showContribution.boolValue;
            
            self.isUnread = savedFilter.isUnread.boolValue;
            self.showMyEntouragesOnly = savedFilter.showMyEntouragesOnly.boolValue;
            self.showFromOrganisationOnly = savedFilter.showFromOrganisationOnly.boolValue;
            self.isIncludingClosed = savedFilter.isIncludingClosed.boolValue;
        }
        else {
            self.showTours = YES;
            self.showDemand = YES;
            self.showContribution = YES;
            
            self.isUnread = NO;
            self.showMyEntouragesOnly = NO;
            self.showFromOrganisationOnly = NO;
            self.isIncludingClosed = YES;
        }
    }
    return self;
}

- (NSArray *)groupHeaders {
    if(IS_PRO_USER)
        return @[
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_entourage_mine_title")
                 ];
    else
        return @[
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_entourage_mine_title")
                 ];
}

- (NSArray *)toGroupedArray {
    if(IS_PRO_USER)
        return [self groupForPro];
    else
        return [self groupForPublic];
}

- (NSArray *)groupForPro {
    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
    if(user.partner == nil)
        return @[
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyTour
                                          active:self.showTours
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                          active:self.showDemand
                                           title:OTLocalizedString(@"filter_entourage_demand")],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                          active:self.showContribution
                                           title:OTLocalizedString(@"filter_entourage_contribution")]
                     ],
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyUnread
                                          active:self.isUnread
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntouragesOnly
                                          active:self.showMyEntouragesOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed
                                          active:self.isIncludingClosed
                                        children:@[]]
                     ]
                 ];
    else
        return @[
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyTour
                                          active:self.showTours
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                          active:self.showDemand
                                           title:OTLocalizedString(@"filter_entourage_demand")],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                          active:self.showContribution
                                           title:OTLocalizedString(@"filter_entourage_contribution")]
                     ],
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyUnread
                                          active:self.isUnread
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntouragesOnly
                                          active:self.showMyEntouragesOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyOrganisationOnly
                                          active:self.showFromOrganisationOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed
                                          active:self.isIncludingClosed
                                        children:@[]]
                     ]
                 ];
}

- (NSArray *)groupForPublic {
    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
    if(user.partner == nil)
        return @[
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                          active:self.showDemand
                                           title:OTLocalizedString(@"filter_entourage_demand")],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                          active:self.showContribution
                                           title:OTLocalizedString(@"filter_entourage_contribution")]
                     ],
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyUnread
                                          active:self.isUnread
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntouragesOnly
                                          active:self.showMyEntouragesOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed
                                          active:self.isIncludingClosed
                                        children:@[]]
                     ]
                 ];
    else
        return @[
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                          active:self.showDemand
                                           title:OTLocalizedString(@"filter_entourage_demand")],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                          active:self.showContribution
                                           title:OTLocalizedString(@"filter_entourage_contribution")]
                     ],
                 @[
                     [OTFeedItemFilter createFor:FeedItemFilterKeyUnread
                                          active:self.isUnread
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntouragesOnly
                                          active:self.showMyEntouragesOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyMyOrganisationOnly
                                          active:self.showFromOrganisationOnly
                                        children:@[]],
                     [OTFeedItemFilter createFor:FeedItemFilterKeyIncludingClosed
                                          active:self.isIncludingClosed
                                        children:@[]]
                     ]
                 ];
}

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result setObject:[self getTourTypes] forKey:@"tour_types"];
    [result setObject:[self getEntourageTypes] forKey:@"entourage_types"];
    [result setObject:@(pageNumber) forKey:@"page"];
    [result setObject:@(pageSize) forKey:@"per"];
    if(self.showMyEntouragesOnly)
        [result setObject:@"true" forKey:@"created_by_me"];
    if (self.showFromOrganisationOnly)
        [result setObject:@"true" forKey:@"show_my_partner_only"];
    NSString *status = [self getStatus];
    if(status)
        [result setObject:[self getStatus] forKey:@"status"];
    return result;
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    switch (filter.key) {
        case FeedItemFilterKeyDemand:
            self.showDemand = filter.active;
            break;
        case FeedItemFilterKeyContribution:
            self.showContribution = filter.active;
            break;
        case FeedItemFilterKeyTour:
            self.showTours = filter.active;
            break;
        case FeedItemFilterKeyUnread:
            self.isUnread = filter.active;
            break;
        case FeedItemFilterKeyMyEntouragesOnly:
            self.showMyEntouragesOnly = filter.active;
            break;
        case FeedItemFilterKeyOrganisation:
            self.showFromOrganisationOnly = filter.active;
            break;
        case FeedItemFilterKeyIncludingClosed:
            self.isIncludingClosed = filter.active;
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
