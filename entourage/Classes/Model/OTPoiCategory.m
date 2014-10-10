//
//  OTPoiCategory.m
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoiCategory.h"

#import "NSDictionary+Parsing.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kCategoryId = @"id";
NSString *const kCategoryName = @"name";

@implementation OTPoiCategory

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoiCategory *)categoryWithJSONDictionnary:(NSDictionary *)dictionary
{
	OTPoiCategory *poiCategory = nil;

	if ([dictionary isKindOfClass:[NSDictionary class]])
	{
		poiCategory = [[OTPoiCategory alloc] init];

		poiCategory.sid = [dictionary numberForKey:kCategoryId];
		poiCategory.name = [dictionary stringForKey:kCategoryName];
	}

	return poiCategory;
}

@end
