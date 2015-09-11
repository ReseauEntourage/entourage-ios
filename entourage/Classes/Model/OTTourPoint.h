//
//  OTTourPoint.h
//  entourage
//
//  Created by Nicolas Telera on 27/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OTTourPoint : NSObject

/********************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSDate *passingTime;

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTourPoint *)tourPointWithJSONDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithLocation:(CLLocation *)location;
- (NSDictionary *)dictionaryForWebservice;

/********************************************************************************/
#pragma mark - Private methods

- (CLLocation *)toLocation;

/********************************************************************************/
#pragma mark - Utils

+ (NSArray *)arrayForWebservice:(NSArray *)tourPoints;
+ (NSMutableArray *)tourPointsWithJSONDictionary:(NSDictionary *)dictionary andKey:(NSString *)key;

@end
