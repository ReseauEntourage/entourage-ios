//
//  OTEntourageService.h
//  entourage
//
//  Created by Mihai Ionescu on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OTEntourageService : NSObject

- (void)entouragesWithStatus:(NSString *)entouragesStatus
                     success:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure;

- (void)entouragesAroundCoordinate:(CLLocationCoordinate2D)coordinate
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure;

@end
