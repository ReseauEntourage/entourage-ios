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
    parameters[kTour] = [tour dictionaryForWebservice];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (success)
                                         {
                                             OTTour *receivedTour = [self tourFromDictionary:responseObject];
                                             success(receivedTour);
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
    parameters[kTour] = [tour dictionaryForWebservice];
    [[OTHTTPRequestManager sharedInstance] PUT:url
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           if (success)
                                           {
                                               OTTour *closedTour = [self tourFromDictionary:responseObject];
                                               success(closedTour);
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