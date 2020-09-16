//
//  OTEntourageService.m
//  entourage
//
//  Created by Mihai Ionescu on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageService.h"
#import "OTHTTPRequestManager.h"
#import "OTAPIConsts.h"

// Models
#import "OTUser.h"
#import "OTEntourage.h"
#import "OTFeedItemJoiner.h"
#import "OTEntourageInvitation.h"

// Helpers
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"
#import "OTEntourageService.h"
#import "OTLocationManager.h"


/**************************************************************************************************/
#pragma mark - Constants

NSString *const kEntourages = @"entourages";
extern NSString *kUsers;

@implementation OTEntourageService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)entouragesAroundCoordinate:(CLLocationCoordinate2D)coordinate
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGES, TOKEN];
    NSDictionary *parameters = @{@"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude)};
    NSLog(@"requesting entourages %@  ...", url);
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSMutableArray *entourages = [self entouragesFromDictionary:data];
         NSLog(@"received %lu ent", (unsigned long)entourages.count);
         if (success)
         {
             success(entourages);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)getEntourageWithId:(NSNumber *)uid
          withSuccess:(void(^)(OTEntourage *))success
              failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat: API_URL_ENTOURAGE_BY_ID, uid];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject) {
         if (success) {
             NSDictionary *entDictionary = [(NSDictionary*)responseObject objectForKey:@"entourage"];
             OTEntourage *ent = [[OTEntourage alloc] initWithDictionary:entDictionary];
             success(ent);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)getEntourageWithStringId:(NSString *)uuid
               withSuccess:(void(^)(OTEntourage *))success
                   failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat: API_URL_ENTOURAGE_BY_ID, uuid];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             NSDictionary *entDictionary = [(NSDictionary*)responseObject objectForKey:@"entourage"];
             OTEntourage *ent = [[OTEntourage alloc] initWithDictionary:entDictionary];
             success(ent);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)joinEntourage:(OTEntourage *)entourage
              success:(void(^)(OTFeedItemJoiner *))success
              failure:(void (^)(NSError *)) failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_REQUEST, entourage.uuid, TOKEN];
    NSLog(@"Join entourage request: %@", url);
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    CLLocationDistance distance = [currentLocation distanceFromLocation:entourage.location];
    NSDictionary *parameteres = @{@"distance": @(distance)};
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameteres
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSDictionary *joinerDictionary = [data objectForKey:@"user"];
         OTFeedItemJoiner *joiner = [[OTFeedItemJoiner alloc ]initWithDictionary:joinerDictionary];
         
         if (success)
         {
             success(joiner);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)joinMessageEntourage:(OTEntourage *)entourage
                     message:(NSString *)message
              success:(void(^)(OTFeedItemJoiner *))success
              failure:(void (^)(NSError *)) failure
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_UPDATE, entourage.uuid, currentUser.sid, TOKEN];
    NSDictionary *parameters = @{@"request": @{@"message":message}};
    NSLog(@"JoinMessage entourage request: %@", url);
    
    [[OTHTTPRequestManager sharedInstance]
         PUTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSDictionary *joinerDictionary = [data objectForKey:@"user"];
             OTFeedItemJoiner *joiner = [[OTFeedItemJoiner alloc] initWithDictionary:joinerDictionary];
             
             if (success)
             {
                 success(joiner);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }
    ];
}

- (void)closeEntourage:(OTEntourage *)entourage
           withOutcome:(BOOL)outcome
      success:(void (^)(OTEntourage *))success
          failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_UPDATE, entourage.uuid, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    NSMutableDictionary *entourageDictionary = [[NSMutableDictionary alloc] initWithDictionary:[entourage dictionaryForWebService]];
    
    entourageDictionary[@"outcome"] = @{@"success": @(outcome)};
    parameters[@"entourage"] = entourageDictionary;
    
    [[OTHTTPRequestManager sharedInstance]
         PUTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             if (success)
             {
                 NSDictionary *entourageDictionary = [(NSDictionary *)responseObject objectForKey:kWSKeyEntourage];
                 OTEntourage *updatedEntourage = [[OTEntourage alloc] initWithDictionary:entourageDictionary];
                 success(updatedEntourage);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }];
}

- (void)reopenEntourage:(OTEntourage *)entourage
      success:(void (^)(OTEntourage *))success
          failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_UPDATE, entourage.uuid, TOKEN];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    
    NSDictionary *entourageDictionary = @{@"status": @"open"};
    parameters[@"entourage"] = entourageDictionary;
    
    [[OTHTTPRequestManager sharedInstance]
         PATCHWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             if (success)
             {
                 NSDictionary *entourageDictionary = [(NSDictionary *)responseObject objectForKey:kWSKeyEntourage];
                 OTEntourage *updatedEntourage = [[OTEntourage alloc] initWithDictionary:entourageDictionary];
                 success(updatedEntourage);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }];
}

- (void)updateEntourageJoinRequestStatus:(NSString *)status
                                 forUser:(NSNumber*)userID
                            forEntourage:(NSString *)uuid
                             withSuccess:(void (^)(void))success
                                 failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_UPDATE, uuid, userID, TOKEN];
    NSDictionary *parameters = @{@"user":@{@"status":status}};
    
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             success();
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)rejectEntourageJoinRequestForUser:(NSNumber *)userID
                             forEntourage:(NSString *)uuid
                              withSuccess:(void (^)(void))success
                                  failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_UPDATE, uuid, userID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     DELETEWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             success();
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)entourageMessagesForEntourage:(NSString *)uuid
                          WithSuccess:(void(^)(NSArray *entourageMessages))success
                              failure:(void (^)(NSError *)) failure
{
    NSString *url = [NSString stringWithFormat:@API_URL_ENTOURAGE_GET_MESSAGES, uuid, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSArray *messages = [self messagesFromDictionary:data];
         if (success)
             success(messages);
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];

}

- (void)sendMessage:(NSString *)message
        onEntourage:(OTEntourage *)entourage
            success:(void(^)(OTFeedItemMessage *))success
            failure:(void (^)(NSError *)) failure
{
    
    NSString *url = [NSString stringWithFormat:@API_URL_ENTOURAGE_SEND_MESSAGE, entourage.uuid, TOKEN];
    
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"content": message}};
    
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:messageDictionary
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSDictionary *messageDictionary = [data objectForKey:@"chat_message"];
         OTFeedItemMessage *message = [[OTFeedItemMessage alloc] initWithDictionary:messageDictionary];
         
         if (success)
         {
             success(message);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)quitEntourage:(OTEntourage *)entourage
         success:(void (^)(void))success
         failure:(void (^)(NSError *error))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_QUIT, entourage.uuid, USER_ID, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     DELETEWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject) {
         if (success)
             success();
     }
     andFailure:^(NSError *error) {
         if (failure)
             failure(error);
     }];
}

- (void)getUsersForEntourageWithId:(NSString *)uuid
                               uid:(NSNumber*)uid
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure {
    NSString *format = @"%@/%@/users.json?context=group_feed&token=%@";
    id entourageId = uuid ? uuid : uid;
    NSString *url = [NSString stringWithFormat:format, kEntourages, entourageId, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSArray *joiners = [data objectForKey:kUsers];
         if (success) {
             success([OTFeedItemJoiner arrayForWebservice:joiners]);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];    
}

- (void)readEntourageMessages:(NSString *)uuid
                 success:(void (^)(void))success
                 failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat: @API_URL_ENTOURAGE_SET_READ_MESSAGES, uuid, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if (success)
         {
             success();
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)retrieveEntourage:(OTEntourage *)entourage
                 fromRank:(NSNumber *)rank
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *))failure {
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    CLLocationDistance distance = [currentLocation distanceFromLocation:entourage.location];
    NSString *url = [NSString stringWithFormat: API_URL_ENTOURAGE_RETRIEVE, entourage.uuid, (int)distance/1000, [rank stringValue], TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject) {
         if(success)
            success();
     }
     andFailure:^(NSError *error) {
         if(failure)
            failure(error);
     }];
}


/**************************************************************************************************/
#pragma mark - Private methods

- (NSArray *)messagesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSArray *messagesDictionaries = [data objectForKey:@"chat_messages"];
    for (NSDictionary *messageDictionary in messagesDictionaries)
    {
        OTFeedItemMessage *message = [[OTFeedItemMessage alloc] initWithDictionary:messageDictionary];
        [messages addObject:message];
    }
    return messages;
}

- (NSMutableArray *)entouragesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *entourages = [NSMutableArray new];
    NSArray *jsonEntourages = data[kEntourages];
    
    if ([jsonEntourages isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonEntourages)
        {
            OTEntourage *ent = [[OTEntourage alloc]initWithDictionary:dictionary];
            if (ent)
            {
                [entourages addObject:ent];
            }
        }
    }
    return entourages;
}

@end
