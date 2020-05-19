//
//  OTOnboardingService.h
//  entourage
//
//  Created by Ciprian Habuc on 07/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

@interface OTOnboardingService : NSObject

- (void)setupNewUserWithPhone:(NSString*)phone
                      success:(void (^)(OTUser *onboardUser))success
                      failure:(void (^)(NSError *error))failure;
- (void)setupNewUserWithUser:(OTUser*)user
                     success:(void (^)(OTUser *onboardUser))success
                     failure:(void (^)(NSError *error))failure;

@end
