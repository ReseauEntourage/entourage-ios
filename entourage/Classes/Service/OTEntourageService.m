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

// Helpers
#import "NSUserDefaults+OT.h"

@implementation OTEntourageService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)entouragesWithStatus:(NSString *)entouragesStatus
                     success:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_entourages", @""), [[NSUserDefaults standardUserDefaults] currentUser].token, entouragesStatus];
    NSLog(@"requesting entourages %@ with parameters %@ ...", url, @"0");
    
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSMutableArray *tours = [self toursFromDictionary:data];
         NSLog(@"received %lu ent", (unsigned long)tours.count);
         if (success)
         {
             success(tours);
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

/**************************************************************************************************/
#pragma mark - Private methods

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
