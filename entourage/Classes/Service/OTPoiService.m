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

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kCategories = @"categories";
NSString *const kPOIs = @"pois";
NSString *const kAPIPoiRoute = @"map.json";

@implementation OTPoiService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)allPoisWithSuccess:(void (^)(NSArray *, NSArray *))success failure:(void (^)(NSError *))failure
{
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:kAPIPoiRoute
     andParameters:[OTHTTPRequestManager commonParameters]
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         
         NSMutableArray *categories = [self categoriesFromDictionary:data];
         NSMutableArray *pois = [self poisFromDictionary:data];
         
         if (success)
         {
             success(categories, pois);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)poisAroundCoordinate:(CLLocationCoordinate2D)coordinate
                    distance:(CLLocationDistance)distance
                     success:(void (^)(NSArray *, NSArray *))success
                     failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"latitude"] = @(coordinate.latitude);
    parameters[@"longitude"] = @(coordinate.longitude);
    parameters[@"distance"] = @(distance);
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:kAPIPoiRoute
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         
         NSMutableArray *categories = [self categoriesFromDictionary:data];
         NSMutableArray *pois = [self poisFromDictionary:data];
         
         if (success)
         {
             success(categories, pois);
         }
     }
     andFailure:^(NSError *error)
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
            OTPoi *poi = [OTPoi poiWithJSONDictionary:dictionary];
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
            OTPoiCategory *category = [OTPoiCategory categoryWithJSONDictionary:dictionary];
            if (category)
            {
                [categories addObject:category];
            }
        }
    }
    return categories;
}

@end
