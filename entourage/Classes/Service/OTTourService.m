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

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kTour = @"tour";

NSString *const kTourPoints = @"tour_points";

NSString *const kAPITourRoute = @"tours";

@implementation  OTTourService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)sendTour:(OTTour *)tour
     withSuccess:(void (^)(OTTour *receivedTour))success
         failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@.json?token=%@", kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (success)
                                         {
                                             OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                             success(updatedTour);
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (failure)
                                         {
                                             failure(error);
                                         }
                                     }];
}

- (void)closeTour:(OTTour *)tour
      withSuccess:(void (^)(OTTour *closedTour))success
          failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@/%@.json?token=%@", kAPITourRoute, [tour sid], [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    [[OTHTTPRequestManager sharedInstance] PUT:url
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           if (success)
                                           {
                                               OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                               success(updatedTour);
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           if (failure)
                                           {
                                               failure(error);
                                           }
                                       }];
}

- (void)sendTourPoint:(NSMutableArray *)tourPoints
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTTour *updatedTour))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@.json?token=%@", kAPITourRoute, tourId, kTourPoints, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTourPoints] = [OTTourPoint arrayForWebservice:tourPoints];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if (success)
                                            {
                                                OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                                success(updatedTour);
                                            }
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

@end