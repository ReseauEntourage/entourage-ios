//
//  OTTourPoint.m
//  entourage
//
//  Created by Nicolas Telera on 27/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "OTTourPoint.h"

#import "NSDictionary+Parsing.h"

NSString *const kTourPointLatitude = @"latitude";
NSString *const kTourPointLongitude = @"longitude";

@implementation OTTourPoint

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTourPoint *)tourPointWithJSONDictionary:(NSDictionary *)dictionary
{
    OTTourPoint *tourPoint = nil;
    
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        tourPoint = [[OTTourPoint alloc] init];
        tourPoint.latitude = [[dictionary numberForKey:kTourPointLatitude] doubleValue];
        tourPoint.longitude = [[dictionary numberForKey:kTourPointLongitude] doubleValue];
    }
    
    return tourPoint;
}

- (instancetype)initWithLocation:(CLLocation *)location
{
    self = [super init];
    if (self) {
        _latitude = location.coordinate.latitude;
        _longitude = location.coordinate.longitude;
    }
    return self;
}

- (NSDictionary *)dictionaryForWebservice
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kTourPointLatitude] = [NSNumber numberWithDouble:self.latitude];
    dictionary[kTourPointLongitude] = [NSNumber numberWithDouble:self.longitude];
    
    return dictionary;
}

/********************************************************************************/
#pragma mark - Private methods

- (CLLocation *)toLocation
{
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

/********************************************************************************/
#pragma mark - Utils

+ (NSArray *)arrayForWebservice:(NSArray *)tourPoints
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (OTTourPoint *tourPoint in tourPoints) {
        [array addObject:[tourPoint dictionaryForWebservice]];
    }
    
    return array;
}

+ (NSMutableArray *)tourPointsWithJSONDictionary:(NSDictionary *)dictionary andKey:(NSString *)key
{
    NSMutableArray *tourPoints = [NSMutableArray new];
    for (id parsedObject in [dictionary objectForKey:key]) {
        OTTourPoint *point = [OTTourPoint tourPointWithJSONDictionary:parsedObject];
        [tourPoints addObject:point];
    }
    return tourPoints;
}

@end

