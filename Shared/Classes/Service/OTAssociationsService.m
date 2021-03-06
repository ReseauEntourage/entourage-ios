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
NSString *const kAssociation = @"partner";

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

- (void)addAssociation:(OTAssociation *)association withSuccess:(void (^)(OTAssociation *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ADD_PARTNER, USER_ID, TOKEN];
    NSDictionary *parameters = @{ @"partner": @{ @"id": association.aid } };
    [[OTHTTPRequestManager sharedInstance] POSTWithUrl:url andParameters:parameters andSuccess:^(id responseObject) {
        NSDictionary *data = responseObject;
        OTAssociation *updated = [[OTAssociation alloc] initWithDictionary:data];
        if (success)
            success(updated);
    } andFailure:^(NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)deleteAssociation:(OTAssociation *)association withSuccess:(void (^)(OTAssociation *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_DELETE_PARTNER, USER_ID, association.aid, TOKEN];
    [[OTHTTPRequestManager sharedInstance] DELETEWithUrl:url andParameters:nil andSuccess:^(id responseObject) {
        NSDictionary *data = responseObject;
        OTAssociation *updated = [[OTAssociation alloc] initWithDictionary:data];
        if (success)
            success(updated);
    } andFailure:^(NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)getAssociationDetailWithId:(int) partnerId withSuccess: (void (^)(OTAssociation *))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:API_URL_GET_ASSOCIATION_DETAIL,partnerId, TOKEN];
    [[OTHTTPRequestManager sharedInstance] GETWithUrl:url andParameters:nil andSuccess:^(id responseObject) {
        if(success) {
            NSDictionary *data = responseObject;
            NSDictionary *dict = data[kAssociation];
            OTAssociation *association = [[OTAssociation alloc] initWithDictionary:dict];
            success(association);
        }
     }
     andFailure:^(NSError *error)
     {
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
