//
//  OTEncounterService.m
//  entourage
//
//  Created by Nicolas Telera on 08/09/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTEncounterService.h"
#import "OTHTTPRequestManager.h"
#import "OTEncounter.h"
#import "OTConsts.h"
#import "OTTourService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTAPIConsts.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPIEncounterRoute = @"encounters";
NSString *const kEncounters = @"encounters";
NSString *const kEncounter = @"encounter";

@implementation OTEncounterService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)sendEncounter:(OTEncounter *)encounter
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTEncounter *receivedEncounter))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_SEND_ENCOUNTER, kAPITourRoute, tourId, kAPIEncounterRoute, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kEncounter] = [encounter dictionaryForWebService];
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             OTEncounter *receivedEncounter = [self encounterFromDictionary:responseObject];
             success(receivedEncounter);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)updateEncounter:(OTEncounter *)encounter
            withSuccess:(void (^)(OTEncounter *))success
                failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENCOUNTER_UPDATE, encounter.sid, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kEncounter] = [encounter dictionaryForWebService];
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             OTEncounter *updatedEncounter = [self encounterFromDictionary:responseObject];
             success(updatedEncounter);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];

}

- (void)sendEntourage:(OTEntourage *)entourage
          withSuccess:(void (^)(OTEntourage *updatedEntourage))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = API_URL_ENTOURAGE_SEND;
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"entourage"] = [entourage dictionaryForWebService];
    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             if (success) {
                 NSDictionary *entourageDictionary = [(NSDictionary*)responseObject objectForKey:kWSKeyEntourage];
                 OTEntourage *updatedEntourage = [[OTEntourage alloc] initWithDictionary:entourageDictionary];
                 success(updatedEntourage);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)updateEntourage:(OTEntourage *)entourage withSuccess:(void (^)(OTEntourage *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_UPDATE, entourage.uid, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"entourage"] = [entourage dictionaryForWebService];
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             NSDictionary *entourageDictionary = [(NSDictionary *)responseObject objectForKey:kWSKeyEntourage];
             OTEntourage *updatedEntourage = [[OTEntourage alloc] initWithDictionary:entourageDictionary];
             success(updatedEntourage);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

/**************************************************************************************************/
#pragma mark -  methods

- (OTEncounter *)encounterFromDictionary:(NSDictionary *)data
{
    OTEncounter *encounter;
    NSDictionary *jsonEncounters = data[kEncounter];
    
    if ([jsonEncounters isKindOfClass:[NSDictionary class]])
    {
        encounter = [OTEncounter encounterWithJSONDictionary:jsonEncounters];
    }
    return encounter;
}

- (NSMutableArray *)encountersFromDictionary:(NSDictionary *)data
{
    NSMutableArray *encounters = [NSMutableArray array];
    NSArray *jsonEncounters = data[kEncounters];
    
    if ([jsonEncounters isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonEncounters)
        {
            OTEncounter *encounter = [OTEncounter encounterWithJSONDictionary:dictionary];
            if (encounter)
            {
                [encounters addObject:encounter];
            }
        }
    }
    return encounters;
}

@end
