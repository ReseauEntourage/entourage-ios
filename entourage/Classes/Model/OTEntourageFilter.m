//
//  OTEntourageFilter.m
//  entourage
//
//  Created by Mihai Ionescu on 21/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageFilter.h"

#pragma mark - Entourage Filter Keys

NSString* const kEntourageFilterMaraudeMedical = @"EntourageFilterMaraudeMedical";
NSString* const kEntourageFilterMaraudeBarehands = @"EntourageFilterMaraudeBarehands";
NSString* const kEntourageFilterMaraudeAlimentary = @"EntourageFilterMaraudeAlimentary";

NSString* const kEntourageFilterEntourageDemand = @"EntourageFilterEntourageDemand";
NSString* const kEntourageFilterentourageContribution = @"EntourageFilterentourageContribution";
NSString* const kEntourageFilterEntourageShowTours = @"EntourageFilterEntourageShowTours";
NSString* const kEntourageFilterEntourageOnlyMyEntourages = @"EntourageFilterMaraudeOnlyMyEntourages";

NSString* const kEntourageFilterTimeframe = @"EntourageFilterTimeframe";

#pragma mark - OTEntourageFilter

@interface OTEntourageFilter ()

@property NSMutableDictionary *filterValues;

@end

@implementation OTEntourageFilter

+(OTEntourageFilter*)sharedInstance {
    
    static OTEntourageFilter* sharedInstance;
    
    static dispatch_once_t entourageFilterToken;
    dispatch_once(&entourageFilterToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // Initial values
        self.filterValues = [[NSMutableDictionary alloc] initWithDictionary: @{
                              kEntourageFilterMaraudeMedical : @YES,
                              kEntourageFilterMaraudeBarehands : @YES,
                              kEntourageFilterMaraudeAlimentary : @YES,
                              
                              kEntourageFilterEntourageDemand : @YES,
                              kEntourageFilterentourageContribution : @YES,
                              kEntourageFilterEntourageShowTours : @YES,
                              kEntourageFilterEntourageOnlyMyEntourages : @NO,
                              
                              kEntourageFilterTimeframe : @FILTER_TIMEFRAME_OPTION_1
                              }
                             copyItems:YES];
        
    }
    return self;
}

- (NSNumber*)valueForFilter:(NSString*)filterKey {
    return [self.filterValues valueForKey:filterKey];
}

- (void)setFilterValue:(NSNumber*)value forKey:(NSString *)key {
    [self.filterValues setObject:value forKey:key];
}

- (NSString*)getTourTypes {
    NSMutableString *tourTypes = [NSMutableString new];
    if ([[self valueForFilter:kEntourageFilterMaraudeMedical] boolValue] == YES) {
        [tourTypes appendString:@"medical"];
    }
    if ([[self valueForFilter:kEntourageFilterMaraudeBarehands] boolValue] == YES) {
        if ([tourTypes length] > 0) [tourTypes appendString:@","];
        [tourTypes appendString:@"barehands"];
    }
    if ([[self valueForFilter:kEntourageFilterMaraudeAlimentary] boolValue] == YES) {
        if ([tourTypes length] > 0) [tourTypes appendString:@","];
        [tourTypes appendString:@"alimentary"];
    }
    
    return tourTypes;
}
- (NSString*)getEntourageTypes {
    NSMutableString *entourageTypes = [NSMutableString new];
    if ([[self valueForFilter:kEntourageFilterEntourageDemand] boolValue] == YES) {
        [entourageTypes appendString:@"ask_for_help"];
    }
    if ([[self valueForFilter:kEntourageFilterentourageContribution] boolValue] == YES) {
        if ([entourageTypes length] > 0) [entourageTypes appendString:@","];
        [entourageTypes appendString:@"contribution"];
    }
    
    return entourageTypes;
}

@end
