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
        self.showHousing = YES;
        self.showHeal = YES;
        self.showRefresh = YES;
        self.showOrientation = YES;
        self.showCaring = YES;
        self.showReinsertion = YES;
        self.showPartners = YES;
    }
    return self;
}

-(BOOL) isDefaultFilters {
    BOOL isDefault = YES;
    
    if (!_showFood || !_showHousing || !_showHeal || !_showRefresh || !_showOrientation || !_showCaring || !_showReinsertion || !_showPartners) {
        isDefault = NO;
    }
    
    return isDefault;
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
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyReinsertion active:self.showReinsertion withImage:@"reinsertYourself"],
                [OTSolidarityGuideFilterItem createFor:SolidarityGuideKeyPartners active:self.showPartners withImage:@"pin_partners_without_shadow"]
              ]
            ];
}

- (NSMutableDictionary *)toDictionaryWithDistance:(CLLocationDistance)distance
                                         Location:(CLLocationCoordinate2D)location {
    NSMutableArray *categoryIds = [NSMutableArray new];
    for (NSArray *values in self.toGroupedArray) {
        for(OTSolidarityGuideFilterItem *item in values) {
            if (item.active) {
                [categoryIds addObject:[NSNumber numberWithInt:item.key]];
            }
        }
    }
    
    NSString *catValue = [categoryIds componentsJoinedByString: @","];
    
    return [NSMutableDictionary dictionaryWithDictionary: @{
                                                            @"latitude": @(location.latitude),
                                                            @"longitude": @(location.longitude),
                                                            @"category_ids": catValue,
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
        case SolidarityGuideKeyPartners:
            self.showPartners = filter.active;
        default:
            break;
    }
}

@end
