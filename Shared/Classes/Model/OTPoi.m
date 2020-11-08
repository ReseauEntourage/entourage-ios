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
NSString *const kPOIAddress = @"address";
NSString *const kPOILatitude = @"latitude";
NSString *const kPOILongitude = @"longitude";
NSString *const kPOIPhone = @"phone";
NSString *const kPOIDetails = @"description";
NSString *const kPOIWebsite = @"website";
NSString *const kPOIEmail = @"email";
NSString *const kImagePrefixName = @"poi_category-new-%d";
NSString *const kPOITransparentImagePrefix = @"poi_transparent_category-%d";
NSString *const kImageDefaultName = @"poi_category-new-0";
NSString *const kPOIPartnerId = @"partner_id";
NSString *const kPOICategories = @"category_ids";

NSString *const kPOIuuid = @"uuid";
NSString *const kPOIHours = @"hours";
NSString *const kPOILanguages = @"languages";
NSString *const kPOISource = @"source";
NSString *const kPOISourceUrl = @"source_url";
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
        poi.partnerId = [dictionary numberForKey:kPOIPartnerId];
        
        poi.categories_id = [NSMutableArray new];
        NSMutableArray *catArray = [dictionary mutableArrayValueForKey:kPOICategories];
        if ([catArray isKindOfClass:[NSMutableArray class]]) {
            for (NSNumber *catId in catArray) {
                [poi.categories_id addObject:catId];
            }
        }
        
        //TODO: a faire le check si soliguide + parsing langue + horaires + uuid + url
        poi.uuid = [dictionary stringForKey:kPOIuuid];
        poi.languageTxt = [dictionary stringForKey:kPOILanguages];
        poi.openTimeTxt  = [dictionary stringForKey:kPOIHours];
        poi.soliguideUrl = [dictionary stringForKey:kPOISourceUrl];
        NSString *source  = [dictionary stringForKey:kPOISource];
        poi.isSoliguide = [source isEqualToString:@"soliguide"];
        
        if (poi.uuid.integerValue) {
            poi.sid = [NSNumber numberWithInteger:poi.uuid.integerValue];
        }
        else {
            poi.sid = nil;
        }
        poi.audience = @"";
        poi.details = @"";
        poi.website = @"";
        poi.email = @"";
	}

	return poi;
}

/********************************************************************************/
#pragma mark - Utils

- (UIImage *)image
{
    int catId = self.categoryId.intValue;
    //Fix Cat 4 deprecated until WS ready
    if (catId == 4) {
        catId = 41;
    }
    
    NSString *imageName = [NSString stringWithFormat:kImagePrefixName, catId];
	UIImage *image = [UIImage imageNamed:imageName] ? [UIImage imageNamed:imageName] : [UIImage imageNamed:kImageDefaultName];
    return image;
}

@end
