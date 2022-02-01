//
//  OTPoi.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPOITransparentImagePrefix;

@interface OTPoi : NSObject

/********************************************************************************/
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
@property(nonatomic, strong) NSNumber *categoryId,*partnerId;
@property(nonatomic,strong) NSMutableArray *categories_id;

@property(nonatomic) BOOL isSoliguide;
@property(nonatomic, strong) NSString *openTimeTxt;
@property(nonatomic, strong) NSString *languageTxt;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *soliguideUrl;
@property(nonatomic, strong) NSNumber *soliguideId;
/********************************************************************************/
#pragma mark - Birth & Death

+ (OTPoi *)poiWithJSONDictionary:(NSDictionary *)dictionary;

/********************************************************************************/
#pragma mark - Utils

- (UIImage *)image;

@end
