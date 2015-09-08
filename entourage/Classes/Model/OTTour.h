//
//  OTTour.h
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { OTVehiculesFeet=0, OTVehiculesCar=1 } OTVehicules;
typedef enum { OTTypesSocial=0, OTTypesOther=1, OTTypesFood=2 } OTTypes;

@interface OTTour : NSObject

/********************************************************************************/
#pragma mark - Getters and Setters

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSString *tourType;
@property (strong, nonatomic) NSString *vehiculeType;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSMutableArray *tourPoints;
@property (strong, nonatomic) NSMutableDictionary *stats;
@property (strong, nonatomic) NSMutableDictionary *organization;

/********************************************************************************/
#pragma mark - Birth & Death

- (id)initWithTourType:(NSString *)tourType andVehiculeType:(NSString *)vehiculeType;
+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebserviceTour;
- (NSDictionary *)dictionaryForWebserviceTourPoints;

/********************************************************************************/
#pragma mark - Utils

@end
