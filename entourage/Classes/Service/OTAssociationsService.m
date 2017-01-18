//
//  OTAssociationsService.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationsService.h"
#import "OTHTTPRequestManager.h"
#import "OTAssociation.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTAPIConsts.h"

NSString *const kAssociations = @"partners";

@implementation OTAssociationsService

- (void)getAllAssociationsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_GET_ALL_ASSOCIATIONS, TOKEN];
    [[OTHTTPRequestManager sharedInstance] GETWithUrl:url andParameters:nil andSuccess:^(id responseObject) {
        if(success) {
            NSDictionary *data = responseObject;
            NSMutableArray *associations = [self associationsFromDictionary:data];
            success(associations);
        }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

- (void)updateAssociation:(OTAssociation *)association isDefault:(BOOL)isDefault withSuccess:(void (^)(OTAssociation *))success failure:(void (^)(NSError *))failure {
        NSString *url = [NSString stringWithFormat:API_URL_UPDATE_DEFAULT, [[NSUserDefaults standardUserDefaults] currentUser].sid, association.aid, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = @{ @"partner": @{ @"default": @(isDefault) } };
    [[OTHTTPRequestManager sharedInstance] PUTWithUrl:url andParameters:parameters andSuccess:^(id responseObject) {
        NSDictionary *data = responseObject;
        OTAssociation *updated = [[OTAssociation alloc] initWithDictionary:data];
        if (success)
            success(updated);
    } andFailure:^(NSError *error) {
        if (failure)
            failure(error);
    }];
}

#pragma mark - private members

- (NSMutableArray *)associationsFromDictionary:(NSDictionary *)data {
    NSMutableArray *associations = [NSMutableArray array];
    NSArray *jsonAssociations = data[kAssociations];
    if ([jsonAssociations isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dictionary in jsonAssociations) {
            OTAssociation *association = [[OTAssociation alloc] initWithDictionary:dictionary];
            if (association)
                [associations addObject:association];
        }
    }
    return associations;
}

@end
