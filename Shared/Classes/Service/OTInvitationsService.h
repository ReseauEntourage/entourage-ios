//
//  OTInvitationsService.h
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTEntourage.h"
#import "OTEntourageInvitation.h"

@interface OTInvitationsService : NSObject

- (void)inviteNumbers:(NSArray *)phoneNumbers
          toEntourage:(OTEntourage *)entourage
              success:(void (^)(void))success
              failure:(void (^)(NSError *error, NSArray *failedNumbers))failure;
- (void)getInvitationsWithStatus:(NSString *)status
                         success:(void (^)(NSArray *))success
                         failure:(void (^)(NSError *))failure;
- (void)acceptInvitation:(OTEntourageInvitation *)invitation
             withSuccess:(void (^)(void))success
                 failure:(void (^)(NSError *))failure;
- (void)rejectInvitation:(OTEntourageInvitation *)invitation
             withSuccess:(void (^)(void))success
                 failure:(void (^)(NSError *))failure;

@end
