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
#import "OTSolidarityGuideFilterItem.h"

@interface OTSolidarityGuideFilter : NSObject

@property (nonatomic) BOOL showFood;
@property (nonatomic) BOOL showHousing;
@property (nonatomic) BOOL showHeal;
@property (nonatomic) BOOL showRefresh;
@property (nonatomic) BOOL showOrientation;
@property (nonatomic) BOOL showCaring;
@property (nonatomic) BOOL showReinsertion;

- (NSArray *)groupHeaders;
- (NSArray *)toGroupedArray;
- (void)updateValue:(OTSolidarityGuideFilter *)filter;
- (NSMutableDictionary *)toDictionaryWithDistance:(CLLocationDistance)distance andLocation:(CLLocationCoordinate2D)location;

@end
