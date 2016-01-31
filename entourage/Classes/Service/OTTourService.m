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
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPITourRoute = @"tours";
NSString *const kTour = @"tour";
NSString *const kTours = @"tours";
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
     }];
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

@end
