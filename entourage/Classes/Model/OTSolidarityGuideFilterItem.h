//
//  OTSolidarityGuideFilterItem.h
//  entourage
//
//  Created by veronica.gliga on 31/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SolidarityGuideKeyFood = 1,
    SolidarityGuideKeyHousing = 2,
    SolidarityGuideKeyHeal = 3,
    SolidarityGuideKeyRefresh = 4,
    SolidarityGuideKeyOrientation = 5,
    SolidarityGuideKeyCaring = 6,
    SolidarityGuideKeyReinsertion = 7
} SolidarityGuideFilters;

@interface OTSolidarityGuideFilterItem : NSObject

@property (nonatomic) SolidarityGuideFilters key;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* image;

+ (OTSolidarityGuideFilterItem *)createFor:(SolidarityGuideFilters)key active:(BOOL)active withImage:(NSString *)image;
+ (OTSolidarityGuideFilterItem *)createFor:(SolidarityGuideFilters)key;
+ (NSString *)categoryStringForKey:(SolidarityGuideFilters)key;

@end
