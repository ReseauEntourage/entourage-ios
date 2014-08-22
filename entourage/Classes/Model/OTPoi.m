//
//  OTPoi.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoi.h"

static NSString *const kJSONNameKey = @"name";
static NSString *const kJSONTypeKey = @"poi_type";
static NSString *const kJSONLatitudeKey = @"latitude";
static NSString *const kJSONLongitudeKey = @"longitude";

@implementation OTPoi

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionnary:(NSDictionary *)dictionary
{
    OTPoi *poi = nil;

    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        poi = [[OTPoi alloc] init];

        poi.name = dictionary[kJSONNameKey];
        poi.type = dictionary[kJSONTypeKey];
        poi.latitude = [(dictionary[kJSONLatitudeKey]) doubleValue];
        poi.longitude = [(dictionary[kJSONLongitudeKey]) doubleValue];
    }

    return poi;
}

@end
