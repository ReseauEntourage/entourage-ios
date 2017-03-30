//
//  OTSolidarityGuideFilters.h
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"
#import <MapKit/MapKit.h>

typedef enum {
    SolidarityGuideKeyFood,
    SolidarityGuideKeyHousing,
    SolidarityGuideKeyHeal,
    SolidarityGuideKeyRefresh,
    SolidarityGuideKeyOrientation,
    SolidarityGuideKeyCaring,
    SolidarityGuideKeyReinsertion
} SolidarityGuideFilters;

@interface OTSolidarityGuideFilters : NSObject

@property (nonatomic) SolidarityGuideFilters key;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* image;

@property (nonatomic) BOOL showFood;
@property (nonatomic) BOOL showHousing;
@property (nonatomic) BOOL showHeal;
@property (nonatomic) BOOL showRefresh;
@property (nonatomic) BOOL showOrientation;
@property (nonatomic) BOOL showCaring;
@property (nonatomic) BOOL showReinsertion;

- (BOOL)updateFilterOnEntourageCreated;
- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before andLocation:(CLLocationCoordinate2D)location;

@end
