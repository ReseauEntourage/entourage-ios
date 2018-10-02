//
//  OTEntourageService.h
//  entourage
//
//  Created by Mihai Ionescu on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OTFeedItemMessage.h"

@class OTEntourage, OTFeedItemJoiner;

@interface OTEntourageService : NSObject

- (void)entouragesAroundCoordinate:(CLLocationCoordinate2D)coordinate
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure;

- (void)getEntourageWithId:(NSNumber *)uid
               withSuccess:(void(^)(OTEntourage *))success
                   failure:(void (^)(NSError *))failure;

- (void)getEntourageWithStringId:(NSString *)uuid
                     withSuccess:(void(^)(OTEntourage *))success
                         failure:(void (^)(NSError *))failure;

- (void)joinEntourage:(OTEntourage *)entourage
              success:(void(^)(OTFeedItemJoiner *))success
              failure:(void (^)(NSError *)) failure;

- (void)joinMessageEntourage:(OTEntourage *)entourage
                     message:(NSString *)message
                     success:(void(^)(OTFeedItemJoiner *))success
                     failure:(void (^)(NSError *)) failure;

- (void)closeEntourage:(OTEntourage *)entourage
           withOutcome:(BOOL)outcome
               success:(void (^)(OTEntourage *))success
               failure:(void (^)(NSError *))failure;

- (void)updateEntourageJoinRequestStatus:(NSString *)status
                                 forUser:(NSNumber*)userID
                            forEntourage:(NSString *)uuid
                             withSuccess:(void (^)(void))success
                                 failure:(void (^)(NSError *))failure;

- (void)rejectEntourageJoinRequestForUser:(NSNumber*)userID
                             forEntourage:(NSString *)uuid
                              withSuccess:(void (^)(void))success
                                  failure:(void (^)(NSError *))failure;

- (void)sendMessage:(NSString *)message
        onEntourage:(OTEntourage *)entourage
            success:(void(^)(OTFeedItemMessage *))success
            failure:(void (^)(NSError *)) failure;

- (void)entourageMessagesForEntourage:(NSString *)uuid
                          WithSuccess:(void(^)(NSArray *entourageMessages))success
                              failure:(void (^)(NSError *)) failure;

- (void)quitEntourage:(OTEntourage *)entourage
         success:(void (^)(void))success
         failure:(void (^)(NSError *error))failure;

- (void)getUsersForEntourageWithId:(NSString *)uuid
                               uid:(NSNumber*)uid
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure;

- (void)readEntourageMessages:(NSString *)uuid
                      success:(void (^)(void))success
                      failure:(void (^)(NSError *))failure;

- (void)retrieveEntourage:(OTEntourage *)entourage
                 fromRank:(NSNumber *)rank
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *))failure;
@end
