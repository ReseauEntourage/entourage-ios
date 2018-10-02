//
//  OTFeedsService.h
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTFeedsService : NSObject

- (void)getAllFeedsWithParameters:(NSDictionary*)parameters
                          success:(void (^)(NSMutableArray *feeds))success
                          failure:(void (^)(NSError *error))failure;

- (void)getMyFeedsWithParameters:(NSDictionary*)parameters
                     success:(void (^)(NSArray *feeds))success
                     failure:(void (^)(NSError *error))failure;

- (void)getEventsWithParameters:(NSDictionary*)parameters
                        success:(void (^)(NSMutableArray *feeds))success
                        failure:(void (^)(NSError *error))failure;

@end
