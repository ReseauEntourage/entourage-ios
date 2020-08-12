//
//  OTSolidarityGuideFilterItem.m
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFilterItem.h"
#import "OTConsts.h"

@implementation OTSolidarityGuideFilterItem

+ (OTSolidarityGuideFilterItem *)createFor:(SolidarityGuideFilters)key active:(BOOL)active withImage:(NSString *)image {
    OTSolidarityGuideFilterItem *result = [OTSolidarityGuideFilterItem new];
    result.key = key;
    result.active = active;
    result.title = [self categoryStringForKey:key];
    result.image = image;
    
    return result;
}

+ (OTSolidarityGuideFilterItem *)createFor:(SolidarityGuideFilters)key {
    OTSolidarityGuideFilterItem *result = [OTSolidarityGuideFilterItem new];
    result.key = key;
    result.title = [self categoryStringForKey:key];
    
    return result;
}

+ (NSString *)categoryStringForKey:(SolidarityGuideFilters)key {
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
            case SolidarityGuideKeyPartners:
            return OTLocalizedString(@"guide_display_partners");
            
        default:
            return @"";
    }
}

@end
