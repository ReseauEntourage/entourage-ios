//
//  OTTourService.m
//  entourage
//
//  Created by Nicolas Telera on 31/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTTourService.h"
#import "OTHTTPRequestManager.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"
#import "OTTourJoiner.h"
#import "OTTourMessage.h"
#import "OTEncounter.h"
#import "NSDictionary+Parsing.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPITourRoute = @"tours";
NSString *const kAPITourUsersRoute = @"users";
NSString *const kTour = @"tour";
NSString *const kTours = @"tours";
NSString *const kUsers = @"users";
NSString *const kMessages = @"chat_messages";
NSString *const kWSKeyEncounters = @"encounters";
NSString *const kTourPoints = @"tour_points";

@implementation  OTTourService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)sendTour:(OTTour *)tour
     withSuccess:(void (^)(OTTour *))success
         failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_send_tour", @""), kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             OTTour *updatedTour = [self tourFromDictionary:responseObject];
             success(updatedTour);
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

- (void)closeTour:(OTTour *)tour
      withSuccess:(void (^)(OTTour *))success
          failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_close_tour", @""), kAPITourRoute, [tour sid], [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             OTTour *updatedTour = [self tourFromDictionary:responseObject];
             success(updatedTour);
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

- (void)sendTourPoint:(NSMutableArray *)tourPoints
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTTour *))success
              failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_send_point", @""), kAPITourRoute, tourId, kTourPoints, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTourPoints] = [OTTourPoint arrayForWebservice:tourPoints];
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             OTTour *updatedTour = [self tourFromDictionary:responseObject];
             success(updatedTour);
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

- (void)toursAroundCoordinate:(CLLocationCoordinate2D)coordinates
                        limit:(NSNumber *)limit
                     distance:(NSNumber *)distance
                      success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tours_around", @""), kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = @{ @"limit": limit, @"latitude": @(coordinates.latitude), @"longitude": @(coordinates.longitude), @"distance": distance };
    
    [[OTHTTPRequestManager sharedInstance]
             GETWithUrl:url
             andParameters:parameters
             andSuccess:^(id responseObject)
             {
                 NSDictionary *data = responseObject;
                 NSMutableArray *tours = [self toursFromDictionary:data];
                 
                 if (success)
                 {
                     success(tours);
                 }
             }
             andFailure:^(NSError *error)
             {
                 if (failure)
                 {
                     failure(error);
                 }
             }
     ];
}

- (void)sendMessage:(NSString *)message
             onTour:(OTTour *)tour
            success:(void(^)(OTTourMessage *))success
            failure:(void (^)(NSError *)) failure {
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_messages", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"content": message}};

    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:messageDictionary
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             OTTourMessage *message = [self messageFromDictionary:data];
             
             if (success)
             {
                 success(message);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }
     ];
}


- (void)tourUsersJoins:(OTTour *)tour
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure {

    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_users", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    
    [[OTHTTPRequestManager sharedInstance]
             GETWithUrl:url
             andParameters:nil
             andSuccess:^(id responseObject)
             {
                 NSDictionary *data = responseObject;
                 NSArray *joiners = [self usersFromDictionary:data];
                 
                 if (success)
                 {
                     success(joiners);
                 }
             }
             andFailure:^(NSError *error)
             {
                 if (failure)
                 {
                     failure(error);
                 }
             }
     ];
}

- (void)tourMessages:(OTTour *)tour
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure {
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_messages", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSArray *messages = [self messagesFromDictionary:data];
             
             if (success)
             {
                 success(messages);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }
     ];
}

- (void)tourEncounters:(OTTour *)tour
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSError *))failure {
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_encounters", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSArray *encounters = [self tourEncountersFromDictionary:data];
             
             if (success)
             {
                 success(encounters);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }
     ];
}


- (void)toursByUserId:(NSNumber *)userId
       withPageNumber:(NSNumber *)pageNumber
     andNumberPerPage:(NSNumber *)per
              success:(void (^)(NSMutableArray *userTours))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_user_tours", @""),
                     kAPIUserRoute,
                     userId,
                     kTours,
                     [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = @{ @"page" : pageNumber, @"per" : per };
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSMutableArray *userTours = [self toursFromDictionary:data];
         
         if (success)
         {
             success(userTours);
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

- (OTTour *)tourFromDictionary:(NSDictionary *)data
{
    OTTour *tour;
    NSDictionary *jsonTour = data[kTour];
    
    if ([jsonTour isKindOfClass:[NSDictionary class]])
    {
        tour = [OTTour tourWithJSONDictionary:jsonTour];
    }
    return tour;
}

- (NSMutableArray *)toursFromDictionary:(NSDictionary *)data
{
    NSMutableArray *tours = [NSMutableArray new];
    NSArray *jsonTours = data[kTours];
    
    if ([jsonTours isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonTours)
        {
            OTTour *tour = [OTTour tourWithJSONDictionary:dictionary];
            if (tour)
            {
                [tours addObject:tour];
            }
        }
    }
    return tours;
}

#pragma mark User Joins

- (NSArray *)usersFromDictionary:(NSDictionary *)data
{
    NSMutableArray *joiners = [[NSMutableArray alloc] init];
    NSArray *joinersDictionaries = [data objectForKey:kUsers];
    for (NSDictionary *joinerDictionary in joinersDictionaries)
    {
        OTTourJoiner *joiner = [[OTTourJoiner alloc] initWithDictionary:joinerDictionary];
        [joiners addObject:joiner];
    }
    return joiners;
}

- (OTTourJoiner *)joinerFromDictionary:(NSDictionary *)dictionary
{
    OTTourJoiner *joiner = [[OTTourJoiner alloc] initWithDictionary:dictionary];
    return joiner;
}

#pragma mark Chat Messages

- (NSArray *)messagesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSArray *messagesDictionaries = [data objectForKey:kMessages];
    for (NSDictionary *messageDictionary in messagesDictionaries)
    {
        OTTourMessage *message = [[OTTourMessage alloc] initWithDictionary:messageDictionary];
        [messages addObject:message];
    }
    return messages;
}

- (OTTourMessage *)messageFromDictionary:(NSDictionary *)dictionary
{
    OTTourMessage *message = [[OTTourMessage alloc] initWithDictionary:dictionary];
    return message;
}

#pragma mark Encounters
- (NSArray *)tourEncountersFromDictionary:(NSDictionary *)data
{
    NSMutableArray *encounters = [[NSMutableArray alloc] init];
    NSArray *encountersDictionaries = [data objectForKey:kWSKeyEncounters];
    for (NSDictionary *encounterDictionary in encountersDictionaries)
    {
        OTEncounter *encounter = [OTEncounter encounterWithJSONDictionary:encounterDictionary];
        [encounters addObject:encounter];
    }
    return encounters;
}

//- (OTTourMessage *)encounterFromDictionary:(NSDictionary *)dictionary
//{
//    OTTourMessage *message = [[OTTourMessage alloc] initWithDictionary:dictionary];
//    return message;
//}

@end
