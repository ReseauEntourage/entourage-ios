//
//  OTPoiService.m
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTPoiService.h"
#import "OTHTTPRequestManager.h"
#import "OTPoiCategory.h"
#import "OTPoi.h"
#import "OTEncounter.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kCategories = @"categories";
NSString *const kPOIs = @"pois";
NSString *const kEncounters = @"encounters";

NSString *const kAPIPoiRoute = @"map.json";

@implementation OTPoiService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)allPoisWithSuccess:(void (^)(NSArray *categories, NSArray *pois, NSArray *encounters))success failure:(void (^)(NSError *error))failure
{
    [[OTHTTPRequestManager sharedInstance] GET:kAPIPoiRoute parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSDictionary *data = responseObject;

                NSMutableArray *categories = [self categoriesFromDictionary:data];
                NSMutableArray *pois = [self poisFromDictionary:data];
                NSMutableArray *encounters = [self encountersFromDictionary:data];

                if (success)
                {
                    success(categories, pois, encounters);
                }
            }

            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                if (failure)
                {
                    failure(error);
                }
            }];

}

/**************************************************************************************************/
#pragma mark - Private methods

- (NSMutableArray *)poisFromDictionary:(NSDictionary *)data
{
    NSMutableArray *pois = [NSMutableArray array];

    NSArray *jsonPois = data[kPOIs];
    if ([jsonPois isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonPois)
        {
            OTPoi *poi = [OTPoi poiWithJSONDictionnary:dictionary];
            if (poi)
            {
                [pois addObject:poi];
            }
        }
    }
    return pois;
}

- (NSMutableArray *)categoriesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *categories = [NSMutableArray array];

    NSArray *jsonCategories = data[kCategories];
    if ([jsonCategories isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonCategories)
        {
            OTPoiCategory *category = [OTPoiCategory categoryWithJSONDictionnary:dictionary];
            if (category)
            {
                [categories addObject:category];
            }
        }
    }
    return categories;
}

- (NSMutableArray *)encountersFromDictionary:(NSDictionary *)data
{
    NSMutableArray *encounters = [NSMutableArray array];
    
    NSArray *jsonEncounters = data[kEncounters];
    if ([jsonEncounters isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonEncounters)
        {
            OTEncounter *encounter = [OTEncounter encounterWithJSONDictionnary:dictionary];
            if (encounter)
            {
                [encounters addObject:encounter];
            }
        }
    }
    return encounters;
}

@end
