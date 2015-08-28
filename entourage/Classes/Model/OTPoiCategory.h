//
//  OTPoiCategory.h
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kCategoryId;
extern NSString *const kCategoryName;

@interface OTPoiCategory : NSObject

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSString *name;

+ (OTPoiCategory *)categoryWithJSONDictionary:(NSDictionary *)dictionary;
@end
