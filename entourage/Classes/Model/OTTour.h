//
//  OTTour.h
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTourAuthor.h"

typedef enum { OTVehiclesFeet=0, OTVehiclesCar=1 } OTVehicles;
typedef enum { OTTypesMedical=0, OTTypesBareHands=1, OTTypesAlimentary=2 } OTTypes;

@interface OTTour : NSObject

/********************************************************************************/
#pragma mark - Getters and Setters

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *tourType;
@property (strong, nonatomic) NSString *vehicleType;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *joinStatus;
@property (strong, nonatomic) OTTourAuthor *author;
@property (strong, nonatomic) NSMutableArray *tourPoints;
@property (strong, nonatomic) NSMutableDictionary *stats;
@property (strong, nonatomic) NSString *organizationName;
@property (strong, nonatomic) NSString *organizationDesc;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (nonatomic) float distance;

/********************************************************************************/
#pragma mark - Birth & Death

- (id)initWithTourType:(NSString *)tourType andVehicleType:(NSString *)vehicleType;
+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebserviceTour;
- (NSDictionary *)dictionaryForWebserviceTourPoints;

/********************************************************************************/
#pragma mark - Utils

@end
