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
#import "OTTourService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

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
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@.json?token=%@", kAPITourRoute, tourId, kAPIEncounterRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kEncounter] = [encounter dictionaryForWebservice];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if (success) {
                                                OTEncounter *receivedEncounter = [self encounterFromDictionary:responseObject];
                                                success(receivedEncounter);
                                            }
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            if (failure) {
                                                failure(error);
                                            }
                                        }];
}

/**************************************************************************************************/
#pragma mark - Private methods

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
