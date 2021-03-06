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
NSString *const kTourPointPassingTime = @"passing_time";
NSString *const kTourPointAccuracy = @"accuracy";

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
        // Java format : "2015-09-09T08:56:48.065+02:00"
        tourPoint.passingTime = [dictionary dateForKey:kTourPointPassingTime format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (tourPoint.passingTime == nil) {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            tourPoint.passingTime = [dictionary dateForKey:kTourPointPassingTime format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
        tourPoint.accuracy = [[dictionary numberForKey:kTourPointAccuracy] doubleValue];
    }
    
    return tourPoint;
}

- (instancetype)initWithLocation:(CLLocation *)location
{
    self = [super init];
    if (self) {
        _latitude = location.coordinate.latitude;
        _longitude = location.coordinate.longitude;
        _accuracy = location.horizontalAccuracy;
        _passingTime = [NSDate date];
    }
    return self;
}

- (NSDictionary *)dictionaryForWebservice
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kTourPointLatitude] = [NSNumber numberWithDouble:self.latitude];
    dictionary[kTourPointLongitude] = [NSNumber numberWithDouble:self.longitude];
    dictionary[kTourPointPassingTime] = self.passingTime;
    dictionary[kTourPointAccuracy] = [NSNumber numberWithDouble:self.accuracy];
    
    return dictionary;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.latitude forKey:kTourPointLatitude];
    [encoder encodeDouble:self.longitude forKey:kTourPointLongitude];
    [encoder encodeObject:self.passingTime forKey:kTourPointPassingTime];
    [encoder encodeDouble:self.accuracy forKey:kTourPointAccuracy];
   
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        
        self.latitude = [decoder decodeDoubleForKey:kTourPointLatitude];
        self.longitude = [decoder decodeDoubleForKey:kTourPointLongitude];
        self.passingTime = [decoder decodeObjectForKey:kTourPointPassingTime];
        self.accuracy = [decoder decodeDoubleForKey:kTourPointAccuracy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OTTourPoint class]]) {
        OTTourPoint *compare = (OTTourPoint *) object;
        return (_latitude == compare.latitude &&
                _longitude == compare.longitude &&
                _accuracy == compare.accuracy &&
                [_passingTime isEqualToDate:compare.passingTime]);
    } else {
        return false;
    }
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

