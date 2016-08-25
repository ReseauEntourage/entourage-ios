//
//  OTInvitationsService.m
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInvitationsService.h"
#import "OTHTTPRequestManager.h"
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

NSString *const kInvitations = @"invitations";
NSString *const kKeyFailedNumbers = @"failed_numbers";

@implementation OTInvitationsService

- (void)inviteNumbers:(NSArray *)phoneNumbers toEntourage:(OTEntourage *)entourage success:(void (^)())success failure:(void (^)(NSError *, NSArray *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_INVITE, entourage.uid, TOKEN];
    NSDictionary *messageDictionary = @{@"invite" : @{@"mode": @"SMS", @"phone_numbers": phoneNumbers}};
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:messageDictionary
     andSuccess:^(id responseObject)
     {
         if (success)
             success();
     }
     andFailure:^(NSError *error)
     {
         NSArray *failedNumbers = nil;
         NSData *responseData = (NSData *)error.userInfo [AFNetworkingOperationFailingURLResponseDataErrorKey];
         if(responseData) {
             NSError* jsonError;
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
             if(!jsonError)
                 failedNumbers = [json objectForKey:kKeyFailedNumbers];
         }
         if (failure)
             failure(error, failedNumbers);
     }];
}

- (void)entourageGetInvitationsWithStatus:(NSString *)status success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_GET_INVITES, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if(success) {
             NSArray *invitations = [OTEntourageInvitation arrayForWebservice:[responseObject objectForKey:kInvitations]];
             if(!status) {
                 success(invitations);
                 return;
             }
             NSArray *filteredItems = [invitations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(OTEntourageInvitation *item, NSDictionary *bindings) {
                 return [item.status isEqualToString:status];
             }]];
             success(filteredItems);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

- (void)acceptInvitation:(OTEntourageInvitation *)invitation withSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_HANDLE_INVITE, invitation.iid, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if (success)
             success();
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

@end
