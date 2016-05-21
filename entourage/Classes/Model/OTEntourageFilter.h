//
//  OTEntourageFilter.h
//  entourage
//
//  Created by Mihai Ionescu on 21/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kEntourageFilterMaraudeMedical;
extern NSString* const kEntourageFilterMaraudeBarehands;
extern NSString* const kEntourageFilterMaraudeAlimentary;

extern NSString* const kEntourageFilterEntourageDemand;
extern NSString* const kEntourageFilterentourageContribution;
extern NSString* const kEntourageFilterEntourageShowTours;
extern NSString* const kEntourageFilterEntourageOnlyMyEntourages;

extern NSString* const kEntourageFilterTimeframe;

#define FILTER_TIMEFRAME_OPTION_1 24
#define FILTER_TIMEFRAME_OPTION_2 48
#define FILTER_TIMEFRAME_OPTION_3 72

@interface OTEntourageFilter : NSObject

+(OTEntourageFilter*)sharedInstance;

- (NSNumber*)valueForFilter:(NSString*)filterKey;
- (void)setFilterValue:(NSNumber*)value forKey:(NSString *)key;

- (NSString*)getTourTypes;
- (NSString*)getEntourageTypes;

@end
