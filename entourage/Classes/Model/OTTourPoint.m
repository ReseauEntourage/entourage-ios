//
//  OTTourPoint.m
//  entourage
//
//  Created by Nicolas Telera on 27/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTTourPoint.h"

#import "NSDictionary+Parsing.h"

NSString *const kTourPointLatitude = @"latitude";
NSString *const kTourPointLongitude = @"longitude";
NSString *const kTourPointDate = @"date";

@implementation OTTourPoint

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTourPoint *)tourPointWithJSONDictionary:(NSDictionary *)dictionary
{
    OTTourPoint *tourPoint = nil;
    
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        tourPoint = [[OTTourPoint alloc] init];
        
        tourPoint.latitude = [dictionary numberForKey:kTourPointLatitude];
        tourPoint.longitude = [dictionary numberForKey:kTourPointLongitude];
        tourPoint.date = [dictionary dateForKey:kTourPointDate format:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return tourPoint;
}

/********************************************************************************/
#pragma mark - Utils

@end

