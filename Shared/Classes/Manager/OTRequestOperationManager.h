//
//  OTRequestOperationManager.h
//  entourage
//
//  Created by Nicolas Telera on 27/01/2016.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface OTRequestOperationManager : AFHTTPSessionManager

- (void)GETWithUrl:(NSString *)url
     andParameters:(NSDictionary *)parameters
        andSuccess:(void (^)(id responseObject))success
        andFailure:(void (^)(NSError *error))failure;

- (void)POSTWithUrl:(NSString *)url
      andParameters:(NSDictionary *)parameters
         andSuccess:(void (^)(id responseObject))success
         andFailure:(void (^)(NSError *error))failure;

- (void)PUTWithUrl:(NSString *)url
     andParameters:(NSDictionary *)parameters
        andSuccess:(void (^)(id responseObject))success
        andFailure:(void (^)(NSError *error))failure;

- (void)PATCHWithUrl:(NSString *)url
     andParameters:(NSDictionary *)parameters
        andSuccess:(void (^)(id responseObject))success
        andFailure:(void (^)(NSError *error))failure;

- (void)DELETEWithUrl:(NSString *)url
       andParameters:(NSDictionary *)parameters
          andSuccess:(void (^)(id responseObject))success
          andFailure:(void (^)(NSError *error))failure;


@end
