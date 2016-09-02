//
//  OTMyEntouragesFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFilter.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "OTFeedItem.h"

#define FILTER_TOUR_TYPES_KEY @"tour_types"
#define FILTER_ENTOURAGE_TYPES_KEY @"entourage_types"
#define FILTER_STATUS_KEY @"status"
#define ALL_STATUS_STRING @"all"
#define PAGE_NUMBER_KEY @"page"
#define PAGE_SIZE_KEY @"per"
#define TIMEFRAME_KEY @"time_range"
#define ORGANISER_KEY @"created_by_me"
#define INVITED_KEY @"accepted_invitation"

@interface OTMyEntouragesFilter ()

@property (nonatomic, strong) OTUser *currentUser;

@end

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
        self.timeframeInHours = 8*24;
        self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    }
    return self;
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
