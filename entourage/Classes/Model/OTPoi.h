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

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *type;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

/**************************************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionnary:(NSDictionary *)dictionary;

@end
