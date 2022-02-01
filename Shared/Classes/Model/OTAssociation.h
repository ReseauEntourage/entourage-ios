//
//  OTAssociation.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAssociation : NSObject

@property (strong, nonatomic) NSNumber *aid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *largeLogoUrl;
@property (strong, nonatomic) NSString *smallLogoUrl;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic, nullable) NSString *phone;
@property (strong, nonatomic, nullable) NSString *address;
@property (strong, nonatomic, nullable) NSString *websiteUrl;
@property (strong, nonatomic, nullable) NSString *email;
@property (assign, nonatomic) BOOL isDefault;
@property (strong, nonatomic, nullable) NSString *userRoleTitle;
@property(nonatomic) Boolean isCreation,isFollowing;
@property (strong, nonatomic, nullable) NSString *postal_code;
@property (strong, nonatomic, nullable) NSString *donations_needs;
@property (strong, nonatomic, nullable) NSString *volunteers_needs;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
