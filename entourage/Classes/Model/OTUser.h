//
//  OTUser.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyToken;

@interface OTUser : NSObject

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *token;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
