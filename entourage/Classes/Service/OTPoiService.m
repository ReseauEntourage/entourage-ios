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
NSString *const kEncounter = @"encounter";

NSString *const kAPIPoiRoute = @"map.json";
NSString *const kAPIEncounterRoute = @"encounters";

@implementation OTPoiService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)allPoisWithSuccess:(void (^)(NSArray *categories, NSArray *pois, NSArray *encounters))success
                   failure:(void (^)(NSError *error))failure
{
    [[OTHTTPRequestManager sharedInstance] GET:kAPIPoiRoute
                                    parameters:[OTHTTPRequestManager commonParameters]
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

- (void)poisAroundCoordinate:(CLLocationCoordinate2D)coordinate
                    distance:(CLLocationDistance)distance
                     success:(void (^)(NSArray *categories, NSArray *pois, NSArray *encounters))success
                     failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"latitude"] = @(coordinate.latitude);
    parameters[@"longitude"] = @(coordinate.longitude);
    parameters[@"distance"] = @(distance);

    [[OTHTTPRequestManager sharedInstance] GET:kAPIPoiRoute
                                    parameters:parameters
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

- (void)sendEncounter:(OTEncounter *)encounter
          withSuccess:(void (^)(OTEncounter *receivedEncounter))success
              failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kEncounter] = [encounter dictionaryForWebservice];
    [[OTHTTPRequestManager sharedInstance] POST:kAPIEncounterRoute
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject)
                                        {
                                            if (success)
                                            {
                                                OTEncounter *receivedEncounter = [self encounterFromDictionary:responseObject];
                                                success(receivedEncounter);
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

- (OTEncounter *)encounterFromDictionary:(NSDictionary *)data
{
    OTEncounter *encounter;
    NSDictionary *jsonEncounters = data[kEncounter];

    if ([jsonEncounters isKindOfClass:[NSDictionary class]])
    {
        encounter = [OTEncounter encounterWithJSONDictionnary:jsonEncounters];
    }
    return encounter;
}

@end
