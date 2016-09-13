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

- (void)getMyFeedsWithStatus:(NSString *)status
               andPageNumber:(NSNumber *)pageNumber
            andNumberPerPage:(NSNumber *)per
                     success:(void (^)(NSMutableArray *userTours))success
                     failure:(void (^)(NSError *error))failure;

@end
