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
    NSLog(@"request to create tour %@...", parameters);
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             
             if (success)
             {
                 OTTour *updatedTour = [self tourFromDictionary:responseObject];
                 NSLog(@"... created tour %d", updatedTour.sid.intValue);
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

- (void)getTourWithId:(NSNumber *)tourId
          withSuccess:(void(^)(OTTour *))success
              failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour", @""), kAPITourRoute, tourId, [[NSUserDefaults standardUserDefaults] currentUser].token];
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
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tours_around", @""), kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
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
            success:(void(^)(OTTourMessage *))success
            failure:(void (^)(NSError *)) failure
{
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_messages", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"content": message}};

    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:messageDictionary
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *messageDictionary = [data objectForKey:@"chat_message"];
             OTTourMessage *message = [self messageFromDictionary:messageDictionary];
             
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
               failure:(void (^)(NSError *))failure
{

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

- (void)updateTourJoinRequestStatus:(NSString *)status
                            forUser:(NSNumber*)userID
                            forTour:(NSNumber*)tourID
                        withSuccess:(void (^)())success
                            failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_join_request_response", @""), tourID, userID, [[NSUserDefaults standardUserDefaults] currentUser].token];
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
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_join_request_response", @""), tourID, userID, [[NSUserDefaults standardUserDefaults] currentUser].token];
    
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

- (void)joinTour:(OTTour *)tour
     withMessage:(NSString*)message
         success:(void(^)(OTTourJoiner *))success
         failure:(void (^)(NSError *)) failure {
    
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_tour_users", @""), kTours, tour.sid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = @{@"request":@{@"message":message}};
    parameters = nil; //TODO: remove on version 1.2
    NSLog(@"Join request: %@", url);
    
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *joinerDictionary = [data objectForKey:@"user"];
             OTTourJoiner *joiner = [[OTTourJoiner alloc ]initWithDictionary:joinerDictionary];
             
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
   
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_quit_tour", @""), kTours, tour.sid, [[NSUserDefaults standardUserDefaults] currentUser].sid, [[NSUserDefaults standardUserDefaults] currentUser].token];
    
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
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_user_tours", @""),
                     kAPIUserRoute,
                     userId,
                     kTours,
                     [[NSUserDefaults standardUserDefaults] currentUser].token];
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

- (void)entouragesWithStatus:(NSString *)entouragesStatus
                     success:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_entourages", @""), [[NSUserDefaults standardUserDefaults] currentUser].token, entouragesStatus];
    //NSDictionary *parameters = @{ @"limit": limit, @"latitude": @(coordinates.latitude), @"longitude": @(coordinates.longitude), @"distance": distance };
    NSLog(@"requesting entourages %@ with parameters %@ ...", url, @"0");
   
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSMutableArray *tours = [self toursFromDictionary:data];
             NSLog(@"received %lu ent", (unsigned long)tours.count);
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
