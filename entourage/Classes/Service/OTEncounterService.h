//
//  OTEncounterService.h
//  entourage
//
//  Created by Nicolas Telera on 08/09/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class OTEncounter;

@interface OTEncounterService : NSObject

- (void)sendEncounter:(OTEncounter *)encounter
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTEncounter *sentEncounter))success
              failure:(void (^)(NSError *error))failure;


- (NSMutableArray *)encountersFromDictionary:(NSDictionary *)data;
- (OTEncounter *)encounterFromDictionary:(NSDictionary *)data;

@end
