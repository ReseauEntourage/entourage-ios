//
//  OTSolidarityGuideFilters.m
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilters.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"

@implementation OTSolidarityGuideFilters

- (instancetype)init {
    self = [super init];
    if(self) {
        self.showFood = YES;
        self.showHousing = NO;
        self.showHeal = NO;
        self.showRefresh = YES;
        self.showOrientation = YES;
        self.showCaring = YES;
        self.showReinsertion = YES;
    }
    return self;
}

- (NSArray *)groupHeaders {
    return @[OTLocalizedString(@"filter_solidarity_guide_categories")];
}

- (NSArray *)toGroupedArray {
    return @[
                [self createFor:SolidarityGuideKeyFood active:self.showFood],
                [self createFor:SolidarityGuideKeyHousing active:self.showHousing],
                [self createFor:SolidarityGuideKeyHeal active:self.showHeal],
                [self createFor:SolidarityGuideKeyRefresh active:self.showRefresh],
                [self createFor:SolidarityGuideKeyOrientation active:self.showOrientation],
                [self createFor:SolidarityGuideKeyCaring active:self.showCaring],
                [self createFor:SolidarityGuideKeyReinsertion active:self.showOrientation]
            ];
}

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize {
    return [NSMutableDictionary new];
}

- (void)updateValue:(OTSolidarityGuideFilters *)filter {
}

#pragma mark - private methods

- (OTSolidarityGuideFilters *)createFor:(SolidarityGuideFilters)key active:(BOOL)active {
    OTSolidarityGuideFilters *result = [OTSolidarityGuideFilters new];
    result.key = key;
    result.active = active;
    result.title = [self stringForKey:key];
    return result;
}

- (NSString *)stringForKey:(SolidarityGuideFilters)key {
    switch (key) {
        case SolidarityGuideKeyFood:
            return OTLocalizedString(@"guide_display_feed");
        case SolidarityGuideKeyHousing:
            return OTLocalizedString(@"guide_display_housing");
        case SolidarityGuideKeyHeal:
            return OTLocalizedString(@"guide_display_heal");
        case SolidarityGuideKeyRefresh:
            return OTLocalizedString(@"guide_display_refresh");
        case SolidarityGuideKeyOrientation:
            return OTLocalizedString(@"guide_display_orientation");
        case SolidarityGuideKeyCaring:
            return OTLocalizedString(@"guide_display_caring");
        case SolidarityGuideKeyReinsertion:
            return OTLocalizedString(@"guide_display_reinsertion");
        default:
            return @"";
    }
}

@end
