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
#import "OTTourJoiner.h"


// Helpers
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kEntourages = @"entourages";

@implementation OTEntourageService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)entouragesAroundCoordinate:(CLLocationCoordinate2D)coordinate
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGES, [[NSUserDefaults standardUserDefaults] currentUser].token ];
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

- (void)joinEntourage:(OTEntourage *)entourage
              success:(void(^)(OTTourJoiner *))success
              failure:(void (^)(NSError *)) failure
{
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_REQUEST, entourage.uid,  [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = nil;
    NSLog(@"Join request: %@", url);
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSDictionary *joinerDictionary = [data objectForKey:@"user"];
         OTTourJoiner *joiner = [[OTTourJoiner alloc ]initWithDictionary:joinerDictionary];
         
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

- (void)updateEntourageJoinRequestStatus:(NSString *)status
                                 forUser:(NSNumber*)userID
                            forEntourage:(NSNumber*)entourageID
                             withSuccess:(void (^)())success
                                 failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_UPDATE, entourageID, userID, [[NSUserDefaults standardUserDefaults] currentUser].token];
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

- (void)rejectEntourageJoinRequestForUser:(NSNumber*)userID
                             forEntourage:(NSNumber*)entourageID
                              withSuccess:(void (^)())success
                                  failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_JOIN_UPDATE, entourageID, userID, [[NSUserDefaults standardUserDefaults] currentUser].token];
    
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

- (void)entourageMessagesForEntourage:(NSNumber *)entourageID
                          WithSuccess:(void(^)(NSArray *entourageMessages))success
                              failure:(void (^)(NSError *)) failure
{
    NSString *url = [NSString stringWithFormat:@API_URL_ENTOURAGE_GET_MESSAGES, entourageID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSArray *messages = [self messagesFromDictionary:data];
         
         if (success)
         {
             success(messages);
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

- (void)sendMessage:(NSString *)message
        onEntourage:(OTEntourage *)entourage
            success:(void(^)(OTTourMessage *))success
            failure:(void (^)(NSError *)) failure
{
    
    NSString *url = [NSString stringWithFormat:@API_URL_ENTOURAGE_SEND_MESSAGE, entourage.uid, TOKEN];
    
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"content": message}};
    
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:messageDictionary
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSDictionary *messageDictionary = [data objectForKey:@"chat_message"];
         OTTourMessage *message = [[OTTourMessage alloc] initWithDictionary:messageDictionary];
         
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


/**************************************************************************************************/
#pragma mark - Private methods

- (NSArray *)messagesFromDictionary:(NSDictionary *)data
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSArray *messagesDictionaries = [data objectForKey:@"chat_messages"];
    for (NSDictionary *messageDictionary in messagesDictionaries)
    {
        OTTourMessage *message = [[OTTourMessage alloc] initWithDictionary:messageDictionary];
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
