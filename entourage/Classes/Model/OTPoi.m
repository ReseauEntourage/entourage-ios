//
//  OTPoi.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoi.h"

#import "NSDictionary+Parsing.h"

NSString *const kPOIId = @"id";
NSString *const kPOICategoryId = @"category_id";
NSString *const kPOIName = @"name";
NSString *const kPOIAudience = @"audience";
NSString *const kPOIAddress = @"adress";
NSString *const kPOILatitude = @"latitude";
NSString *const kPOILongitude = @"longitude";
NSString *const kPOIPhone = @"phone";
NSString *const kPOIDetails = @"description";
NSString *const kPOIWebsite = @"website";
NSString *const kPOIEmail = @"email";
NSString *const kImagePrefixName = @"poi_category-%d";
NSString *const kImageDefaultName = @"poi_category-0";

@implementation OTPoi

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionary:(NSDictionary *)dictionary
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

/********************************************************************************/
#pragma mark - Utils

- (UIImage *)image
{
	NSString *imageName = [NSString stringWithFormat:kImagePrefixName, [self.categoryId intValue]];

	return [UIImage imageNamed:imageName] ? [UIImage imageNamed:imageName] : [UIImage imageNamed:kImageDefaultName];
}

@end
