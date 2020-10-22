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

- (void)poisWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *, NSArray *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *authParams = [[OTHTTPRequestManager commonParameters] mutableCopy];
    [authParams addEntriesFromDictionary:parameters];
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:kPOIs
     andParameters:authParams
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

- (void)getDateilpoiWithId:(NSString *)poiUUID
                   success:(void (^)(OTPoi *pois))success
                   failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *authParams = [[OTHTTPRequestManager commonParameters] mutableCopy];
    NSString *url = [NSString stringWithFormat:@"%@/%@",kPOIs,poiUUID];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:authParams
     andSuccess:^(id responseObject){
         NSDictionary *data = responseObject;
         
         if (success) {
             NSDictionary *poiDict = data[@"poi"];
            if ([poiDict isKindOfClass:[NSDictionary class]]) {
                OTPoi *poi = [OTPoi poiWithJSONDictionary:poiDict];
                success(poi);
            }
         }
     }
     andFailure:^(NSError *error) {
         if (failure) {
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
