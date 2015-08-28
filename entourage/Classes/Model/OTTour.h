//
//  OTTour.h
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTTour : NSObject

/********************************************************************************/
#pragma mark - Getters and Setters

@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *locations;

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary;

/********************************************************************************/
#pragma mark - Utils

@end
