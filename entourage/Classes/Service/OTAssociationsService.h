//
//  OTAssociationsService.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAssociation.h"

@interface OTAssociationsService : NSObject

- (void)getAllAssociationsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)updateAssociation:(OTAssociation *)association isDefault:(BOOL)isDefault withSuccess:(void (^)(OTAssociation *))success failure:(void (^)(NSError *))failure;

@end
