//
//  OTPoiCategory.m
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoiCategory.h"

#import "NSDictionary+Parsing.h"
#import "UIColor+entourage.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kCategoryId = @"id";
NSString *const kCategoryName = @"name";

@implementation OTPoiCategory

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoiCategory *)categoryWithJSONDictionary:(NSDictionary *)dictionary
{
	OTPoiCategory *poiCategory = nil;

	if ([dictionary isKindOfClass:[NSDictionary class]])
	{
		poiCategory = [[OTPoiCategory alloc] init];

		poiCategory.sid = [dictionary numberForKey:kCategoryId];
		poiCategory.name = [dictionary stringForKey:kCategoryName];
        poiCategory.color = [OTPoiCategory colorForCategoryId:poiCategory.sid];
	}

	return poiCategory;
}

+ (UIColor *)colorForCategoryId:(NSNumber*)sid {
    if (sid == nil) return [UIColor poiCategory0];
    switch (sid.longValue) {
        case 1:
            return [UIColor poiCategory1];
            break;
        case 2:
            return [UIColor poiCategory2];
            break;
        case 3:
            return [UIColor poiCategory3];
            break;
        case 4:
            return [UIColor poiCategory4];
            break;
        case 5:
            return [UIColor poiCategory5];
            break;
        case 6:
            return [UIColor poiCategory6];
            break;
        case 7:
            return [UIColor poiCategory7];
            break;
        case 8:
            return [UIColor poiCategory8];
            break;
        default:
            return [UIColor poiCategory0];
            break;
    }
}

@end
