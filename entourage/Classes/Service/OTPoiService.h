//
//  OTPoiService.h
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTEncounter;

extern NSString *const kCategories;
extern NSString *const kPOIs;

extern NSString *const kAPIPoiRoute;

@interface OTPoiService : NSObject

- (void)allPoisWithSuccess:(void (^)(NSArray *categories, NSArray *pois, NSArray *encounters))success failure:(void (^)(NSError *error))failure;

- (void)poisAroundCoordinate:(CLLocationCoordinate2D)coordinate2d distance:(CLLocationDistance)distance success:(void (^)(NSArray *categories, NSArray *pois, NSArray *encounters))success failure:(void (^)(NSError *error))failure;

- (void)sendEncounter:(OTEncounter *)encounter withSuccess:(void (^)(OTEncounter *sentEncounter))success failure:(void (^)(NSError *error))failure;

@end
