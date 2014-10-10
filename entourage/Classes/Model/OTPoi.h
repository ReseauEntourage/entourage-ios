//
//  OTPoi.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTPoi : NSObject

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property(nonatomic, strong) NSNumber *sid;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *details;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSString *website;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *audience;
@property(nonatomic, strong) NSNumber *categoryId;

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionnary:(NSDictionary *)dictionary;

@end
