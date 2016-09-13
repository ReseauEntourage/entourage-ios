//
//  OTTour.h
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

typedef enum { OTVehiclesFeet=0, OTVehiclesCar=1 } OTVehicles;
typedef enum { OTTypesMedical=0, OTTypesBareHands=1, OTTypesAlimentary=2 } OTTypes;

#define TOUR_STATUS_ONGOING @"ongoing"
#define TOUR_STATUS_FREEZED @"freezed"

@interface OTTour : OTFeedItem

@property (nonatomic, strong) NSMutableArray *tourPoints;
@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *organizationDesc;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *noMessages;

- (instancetype)initWithTourType:(NSString *)tourType;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebService;

+ (UIColor *)colorForTourType:(NSString*)tourType;

@end
