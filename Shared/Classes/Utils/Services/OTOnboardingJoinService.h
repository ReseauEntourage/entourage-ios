//
//  OTOnboardingJoinService.h
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTEntourageInvitation.h"

@interface OTOnboardingJoinService : NSObject

- (void)checkForJoins:(void(^)(OTEntourageInvitation *joinedEntourage))success withError:(void(^)(NSError *error))failure;

@end
