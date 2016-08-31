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
    NSString *url = [NSString stringWithFormat:OTLocalizedString(@"url_send_encounter"), kAPITourRoute, tourId, kAPIEncounterRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
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

- (void)sendEntourage:(OTEntourage *)entourage
          withSuccess:(void (^)(OTEntourage *updatedEntourage))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = OTLocalizedString(@"url_send_entourage");
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
    parameters[@"entourage"] = [entourage updateDictionaryForWebService];
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
