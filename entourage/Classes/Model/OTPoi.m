//
//  OTPoi.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoi.h"

#import "NSDictionary+Parsing.h"

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

		poi.sid = [dictionary numberForKey:kPOIId];
		poi.name = [dictionary stringForKey:kPOIName];
		poi.audience = [dictionary stringForKey:kPOIAudience];
		poi.address = [dictionary stringForKey:kPOIAddress];
		poi.latitude = [[dictionary numberForKey:kPOILatitude] doubleValue];
		poi.longitude = [[dictionary numberForKey:kPOILongitude] doubleValue];
		poi.phone = [dictionary stringForKey:kPOIPhone];
		poi.details = [dictionary stringForKey:kPOIDetails];
		poi.website = [dictionary stringForKey:kPOIWebsite];
		poi.email = [dictionary stringForKey:kPOIEmail];
		poi.categoryId = [dictionary numberForKey:kPOICategoryId];
	}

	return poi;
}

@end
