//
//  OTPoi.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoi.h"

static NSString *const kPOIId = @"id";
static NSString *const kPOICategoryId = @"category_id";
static NSString *const kPOIName = @"name";
static NSString *const kPOIAudience = @"audience";
static NSString *const kPOIAddress = @"adress";
static NSString *const kPOILatitude = @"latitude";
static NSString *const kPOILongitude = @"longitude";
static NSString *const kPOIPhone = @"phone";
static NSString *const kPOIDetails = @"description";
static NSString *const kPOIWebsite = @"website";
static NSString *const kPOIEmail = @"email";

@implementation OTPoi

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionnary:(NSDictionary *)dictionary
{
    OTPoi *poi = nil;

    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        poi = [[OTPoi alloc] init];

        poi.sid = dictionary[kPOIId];
        poi.name = dictionary[kPOIName];
        poi.audience = dictionary[kPOIAudience];
        poi.address = dictionary[kPOIAddress];
        poi.latitude = [(dictionary[kPOILatitude]) doubleValue];
        poi.longitude = [(dictionary[kPOILongitude]) doubleValue];
        poi.phone = dictionary[kPOIPhone];
        poi.details = dictionary[kPOIDetails];
        poi.website = dictionary[kPOIWebsite];
        poi.email = dictionary[kPOIEmail];
        poi.categoryId = dictionary[kPOICategoryId];
    }

    return poi;
}

@end
