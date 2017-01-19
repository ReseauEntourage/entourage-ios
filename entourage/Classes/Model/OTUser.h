//
//  OTUser.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTOrganization.h"

extern NSString *const kKeyToken;

#define USER_TYPE_PRO       @"pro"
#define USER_TYPE_PUBLIC    @"public"

@interface OTUser : NSObject

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *avatarKey;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSNumber *tourCount;
@property (strong, nonatomic) NSNumber *entourageCount;
@property (strong, nonatomic) NSNumber *encounterCount;
@property (strong, nonatomic) OTOrganization *organization;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebservice;

/*
 * Returns true if it's a pro user
 */
- (BOOL)isPro;

@end
