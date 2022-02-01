//
//  OTPoiService.h
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OTPoi.h"

extern NSString *const kCategories;
extern NSString *const kPOIs;

extern NSString *const kAPIPoiRoute;

@interface OTPoiService : NSObject

- (void)allPoisWithSuccess:(void (^)(NSArray *categories, NSArray *pois))success
                   failure:(void (^)(NSError *error))failure;

- (void)poisWithParameters:(NSDictionary *)parameters
                   success:(void (^)(NSArray *categories, NSArray *pois))success
                   failure:(void (^)(NSError *error))failure;

- (void)getDateilpoiWithId:(NSString *)poiUUID
                   success:(void (^)(OTPoi *pois))success
                   failure:(void (^)(NSError *error))failure;

@end
