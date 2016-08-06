//
//  OTTourService.h
//  entourage
//
//  Created by Nicolas Telera on 31/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class OTTour, OTFeedItemMessage, OTFeedItemJoiner;

extern NSString *const kAPITourRoute;

@interface OTTourService : NSObject

- (void)sendTour:(OTTour *)tour
     withSuccess:(void (^)(OTTour *sentTour))success
         failure:(void (^)(NSError *error))failure;

- (void)closeTour:(OTTour *)tour
      withSuccess:(void (^)(OTTour *closedTour))success
          failure:(void (^)(NSError *error))failure;

- (void)sendTourPoint:(NSMutableArray *)tourPoints
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTTour *updatedTour))success
              failure:(void (^)(NSError *error))failure;

- (void)getTourWithId:(NSNumber *)tourId
          withSuccess:(void(^)(OTTour *))success
              failure:(void (^)(NSError *))failure;

- (void)toursAroundCoordinate:(CLLocationCoordinate2D) coordinates
                               limit:(NSNumber *)limit
                            distance:(NSNumber *)distance
                             success:(void (^)(NSMutableArray *closeTours))success
                             failure:(void (^)(NSError *error))failure;

- (void)joinTour:(OTTour *)tour
         success:(void(^)(OTFeedItemJoiner *))success
         failure:(void (^)(NSError *)) failure;

- (void)joinMessageTour:(OTTour*)tour
                message:(NSString*)message
                success:(void(^)(OTFeedItemJoiner *))success
                failure:(void (^)(NSError *)) failure;

- (void)updateTourJoinRequestStatus:(NSString *)status
                            forUser:(NSNumber*)userID
                            forTour:(NSNumber*)tourID
                        withSuccess:(void (^)())success
                            failure:(void (^)(NSError *))failure;

- (void)rejectTourJoinRequestForUser:(NSNumber*)userID
                              forTour:(NSNumber*)tourID
                          withSuccess:(void (^)())success
                              failure:(void (^)(NSError *))failure;

- (void)tourUsersJoins:(OTTour *)tour
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure;

- (void)quitTour:(OTTour *)tour
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;


- (void)sendMessage:(NSString *)message
             onTour:(OTTour *)tour
            success:(void(^)(OTFeedItemMessage *))success
            failure:(void (^)(NSError *)) failure;

- (void)tourMessages:(OTTour *)tour
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSError *))failure;

- (void)tourEncounters:(OTTour *)tour
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure;

- (void)toursByUserId:(NSNumber *)userId
       withPageNumber:(NSNumber *)pageNumber
     andNumberPerPage:(NSNumber *)per
              success:(void (^)(NSMutableArray *userTours))success
              failure:(void (^)(NSError *error))failure;

- (void)toursByUserId:(NSNumber *)userId
           withStatus:(NSString *)status
       andPageNumber:(NSNumber *)pageNumber
     andNumberPerPage:(NSNumber *)per
              success:(void (^)(NSMutableArray *userTours))success
              failure:(void (^)(NSError *error))failure;

@end
