//
//  OTSolidarityGuideFilters.m
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilter.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"

@implementation OTSolidarityGuideFilter

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
            @[
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyFood active:self.showFood withImage:@"eat"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyHousing active:self.showHousing withImage:@"housing"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyHeal active:self.showHeal withImage:@"heal"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyRefresh active:self.showRefresh withImage:@"water"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyOrientation active:self.showOrientation withImage:@"orientate"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyCaring active:self.showCaring withImage:@"lookAfterYourself"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyReinsertion active:self.showReinsertion withImage:@"social_sg"]
              ]
            ];
}

- (NSMutableDictionary *)toDictionaryWithDistance:(CLLocationDistance)distance andLocation:(CLLocationCoordinate2D)location {
    return [NSMutableDictionary dictionaryWithDictionary: @{
                                                            @"latitude": @(location.latitude),
                                                            @"longitude": @(location.longitude),
                                                            @"distance": @(distance),
                                                            }];
}

- (void)updateValue:(OTSolidarityGuideFilterItem *)filter {
    switch (filter.key) {
        case SolidarityGuideKeyFood:
            self.showFood = filter.active;
            break;
        case SolidarityGuideKeyHousing:
            self.showHousing = filter.active;
            break;
        case SolidarityGuideKeyHeal:
            self.showHeal = filter.active;
            break;
        case SolidarityGuideKeyRefresh:
            self.showRefresh = filter.active;
            break;
        case SolidarityGuideKeyOrientation:
            self.showOrientation = filter.active;
            break;
        case SolidarityGuideKeyCaring:
            self.showCaring = filter.active;
            break;
        case SolidarityGuideKeyReinsertion:
            self.showReinsertion = filter.active;
            break;
        default:
            break;
    }
}

@end
