//
//  OTEncounterService.h
//  entourage
//
//  Created by Nicolas Telera on 08/09/2015.
//  Copyright (c) 2015 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OTEntourage.h"


@class OTEncounter;

@interface OTEncounterService : NSObject

- (void)sendEncounter:(OTEncounter *)encounter
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTEncounter *sentEncounter))success
              failure:(void (^)(NSError *error))failure;

- (void)updateEncounter:(OTEncounter *)encounter
            withSuccess:(void (^)(OTEncounter *updatedEncounter))success
                failure:(void (^)(NSError *error))failure;

- (void)sendEntourage:(OTEntourage *)entourage
          withSuccess:(void (^)(OTEntourage *updatedEntourage))success
              failure:(void (^)(NSError *error))failure;

- (void)updateEntourage:(OTEntourage *)entourage
            withSuccess:(void (^)(OTEntourage *updatedEntourage))success
                failure:(void (^)(NSError *error))failure;

- (NSMutableArray *)encountersFromDictionary:(NSDictionary *)data;
- (OTEncounter *)encounterFromDictionary:(NSDictionary *)data;

@end
