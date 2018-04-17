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
#import "OTFeedItemJoiner.h"
#import "OTFeedItemMessage.h"
#import "OTEncounter.h"
#import "NSDictionary+Parsing.h"
#import "OTAPIConsts.h"
#import "OTEntourage.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"

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
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_SEND, kAPITourRoute, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebService];
    NSLog(@"Request to create tour %@...", parameters);
    NSLog(@"request details: %@", tour.debugDescription);
    [[OTHTTPRequestManager sharedInstance]
        POSTWithUrl:url
        andParameters:parameters
        andSuccess:^(id responseObject)
         {
             
             if (success)
             {
                 OTTour *updatedTour = [self tourFromDictionary:responseObject];
                 NSLog(@"... created tour %d", updatedTour.uid.intValue);
                 NSLog(@"response details: %@", updatedTour.debugDescription);
                 
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
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_CLOSE, kAPITourRoute, [tour uid], TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebService];
    
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
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_SEND_POINT, kAPITourRoute, tourId, kTourPoints, TOKEN];
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

- (void)getTourWithId:(NSNumber *)tourId
          withSuccess:(void(^)(OTTour *))success
              failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_TOUR, kAPITourRoute, tourId, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             if (success)
             {
                 OTTour *tour = [self tourFromDictionary:responseObject];
                 success(tour);
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
    NSString *url = [NSString stringWithFormat:API_URL_TOURs_AROUND, kAPITourRoute, TOKEN];
    NSDictionary *parameters = @{ @"per": limit, @"latitude": @(coordinates.latitude), @"longitude": @(coordinates.longitude), @"distance": distance };
    NSLog(@"requesting tours %@ with parameters %@ ...", url, parameters);
    [[OTHTTPRequestManager sharedInstance]
             GETWithUrl:url
             andParameters:parameters
             andSuccess:^(id responseObject)
             {
                 NSDictionary *data = responseObject;
                 NSMutableArray *tours = [self toursFromDictionary:data];
                 NSLog(@"received %lu tours", (unsigned long)tours.count);
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
            success:(void(^)(OTFeedItemMessage *))success
            failure:(void (^)(NSError *)) failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_MESSAGES, kTours, tour.uid, TOKEN];
    
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"content": message}};

    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:messageDictionary
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *messageDictionary = [data objectForKey:@"chat_message"];
             OTFeedItemMessage *message = [self messageFromDictionary:messageDictionary];
             
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

- (void)tourUsers:(OTTour *)tour
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure
{

    NSString *url = [NSString stringWithFormat:API_URL_TOUR_FEED_ITEM_USERS, kTours, tour.uid, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
             GETWithUrl:url
             andParameters:nil
             andSuccess:^(id responseObject)
             {
                 NSDictionary *data = responseObject;
                 NSArray *joiners = [data objectForKey:kUsers];
                 if (success)
                     success([OTFeedItemJoiner arrayForWebservice:joiners]);
             }
             andFailure:^(NSError *error)
             {
                 if (failure)
                     failure(error);
             }
     ];
}

- (void)updateTourJoinRequestStatus:(NSString *)status
                            forUser:(NSNumber *)userID
                            forTour:(NSNumber *)tourID
                        withSuccess:(void (^)())success
                            failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_JOIN_REQUEST_RESPONSE, tourID, userID, TOKEN];
    NSDictionary *parameters = @{@"user":@{@"status":status}};
    
    [[OTHTTPRequestManager sharedInstance]
         PUTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             if (success)
             {
                 success();
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

- (void)rejectTourJoinRequestForUser:(NSNumber*)userID
                              forTour:(NSNumber*)tourID
                          withSuccess:(void (^)())success
                              failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_JOIN_REQUEST_RESPONSE, tourID, userID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         DELETEWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             if (success)
             {
                 success();
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
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_MESSAGES, kTours, tour.uid, TOKEN];
    
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
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_ENCOUNTERS, kTours, tour.uid, TOKEN];
    
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

- (void)joinTour:(OTTour *)tour
         success:(void(^)(OTFeedItemJoiner *))success
         failure:(void (^)(NSError *)) failure {
    
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_JOIN_REQUEST, tour.uid, TOKEN];
    NSLog(@"Join request: %@", url);
    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *joinerDictionary = [data objectForKey:@"user"];
             OTFeedItemJoiner *joiner = [[OTFeedItemJoiner alloc] initWithDictionary:joinerDictionary];
             
             if (success)
             {
                 success(joiner);
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

- (void)joinMessageTour:(OTTour*)tour
                message:(NSString*)message
                success:(void(^)(OTFeedItemJoiner *))success
                failure:(void (^)(NSError *)) failure {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_JOIN_MESSAGE, tour.uid, currentUser.sid, TOKEN];
    NSDictionary *parameters = @{@"request": @{@"message":message}};
    NSLog(@"JoinMessage tour request: %@", url);
    
    [[OTHTTPRequestManager sharedInstance]
         PUTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *joinerDictionary = [data objectForKey:@"user"];
             OTFeedItemJoiner *joiner = [[OTFeedItemJoiner alloc] initWithDictionary:joinerDictionary];
             if (success)
             {
                 success(joiner);
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


- (void)quitTour:(OTTour *)tour
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure {
   
    NSString *url = [NSString stringWithFormat:API_URL_TOUR_QUIT, kTours, tour.uid, USER_ID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         DELETEWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             if (success) {
                 success();
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
    [self toursByUserId:userId withStatus:nil andPageNumber:pageNumber andNumberPerPage:per success:success failure:failure];
}

- (void)toursByUserId:(NSNumber *)userId
           withStatus:(NSString *)status
        andPageNumber:(NSNumber *)pageNumber
     andNumberPerPage:(NSNumber *)per
              success:(void (^)(NSMutableArray *userTours))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_TOURS_USER,
                     kAPIUserRoute,
                     userId,
                     kTours,
                     TOKEN];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"page" : pageNumber, @"per" : per }];
    if (status != nil) {
        [parameters setObject:status forKey:@"status"];
    }
    
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

- (void)readTourMessages:(NSNumber *)tourID
                 success:(void (^)())success
                 failure:(void (^)(NSError *))failure {
      NSString *url = [NSString stringWithFormat: @API_URL_TOUR_SET_READ_MESSAGES, tourID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             success();
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

/**************************************************************************************************/
#pragma mark - Private methods

- (OTTour *)tourFromDictionary:(NSDictionary *)data
{
    OTTour *tour;
    NSDictionary *jsonTour = data[kTour];
    
    if ([jsonTour isKindOfClass:[NSDictionary class]])
    {
        tour = [[OTTour alloc] initWithDictionary:jsonTour];
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
            OTTour *tour = [[OTTour alloc] initWithDictionary:dictionary];
            if (tour)
            {
                [tours addObject:tour];
            }
        }
    }
    return tours;
}

#pragma mark Chat Messages

- (NSArray *)messagesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSArray *messagesDictionaries = [data objectForKey:kMessages];
    for (NSDictionary *messageDictionary in messagesDictionaries)
    {
        OTFeedItemMessage *message = [[OTFeedItemMessage alloc] initWithDictionary:messageDictionary];
        [messages addObject:message];
    }
    return messages;
}

- (OTFeedItemMessage *)messageFromDictionary:(NSDictionary *)dictionary
{
    return [[OTFeedItemMessage alloc] initWithDictionary:dictionary];
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

@end
