//
//  OTUserService.h
//  entourage
//
//  Created by Veronica on 14/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

@interface OTUserService : NSObject

- (void)reportUser:(NSString*)idString
           message:(NSString*)message
           success:(void (^)(OTUser *onboardUser))success
           failure:(void (^)(NSError *error))failure;

- (void)reportEntourage:(NSString*)idString
                message:(NSString*)message
                success:(void (^)(OTUser *onboardUser))success
                failure:(void (^)(NSError *error))failure;
@end
