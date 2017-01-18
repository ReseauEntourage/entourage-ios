//
//  OTAssociation.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAssociation : NSObject

@property (strong, nonatomic) NSNumber *aid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *largeLogoUrl;
@property (strong, nonatomic) NSString *smallLogoUrl;
@property (assign, nonatomic) BOOL isDefault;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
