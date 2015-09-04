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
@property (strong, nonatomic) NSString *tourType;
@property (strong, nonatomic) NSString *vehiculeType;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSMutableArray *tourPoints;
@property (strong, nonatomic) NSMutableDictionary *stats;
@property (strong, nonatomic) NSMutableDictionary *organization;

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebservice;

/********************************************************************************/
#pragma mark - Utils

@end
