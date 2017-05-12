//
//  OTSavedFilter.m
//  entourage
//
//  Created by sergiu.buceac on 10/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSavedFilter.h"
#import "OTNewsFeedsFilter.h"

NSString *const kKeyShowMedical = @"showMedical";
NSString *const kKeyShowSocial = @"showSocial";
NSString *const kKeyShowDistributive = @"showDistributive";
NSString *const kKeyShowDemand = @"showDemand";
NSString *const kKeyShowContribution = @"showContribution";
NSString *const kKeyShowTours = @"showTours";
NSString *const kKeyTimeframe = @"Timeframe";

@implementation OTSavedFilter

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.showMedical forKey:kKeyShowMedical];
    [encoder encodeObject:self.showSocial forKey:kKeyShowSocial];
    [encoder encodeObject:self.showDistributive forKey:kKeyShowDistributive];
    [encoder encodeObject:self.showDemand forKey:kKeyShowDemand];
    [encoder encodeObject:self.showContribution forKey:kKeyShowContribution];
    [encoder encodeObject:self.showTours forKey:kKeyShowTours];
    [encoder encodeObject:self.timeframeInHours forKey:kKeyTimeframe];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.showMedical = [decoder decodeObjectForKey:kKeyShowMedical];
        self.showSocial = [decoder decodeObjectForKey:kKeyShowSocial];
        self.showDistributive = [decoder decodeObjectForKey:kKeyShowDistributive];
        self.showDemand = [decoder decodeObjectForKey:kKeyShowDemand];
        self.showContribution = [decoder decodeObjectForKey:kKeyShowContribution];
        self.showTours = [decoder decodeObjectForKey:kKeyShowTours];
        self.timeframeInHours = [decoder decodeObjectForKey:kKeyTimeframe];
    }
    return self;
}

+ (OTSavedFilter *)fromNewsFeedsFilter:(OTNewsFeedsFilter *)filter {
    OTSavedFilter *new = [OTSavedFilter new];
    new.showMedical = @(filter.showMedical);
    new.showSocial = @(filter.showSocial);
    new.showDistributive = @(filter.showDistributive);
    new.showDemand = @(filter.showDemand);
    new.showContribution = @(filter.showContribution);
    new.showTours = @(filter.showTours);
    new.timeframeInHours = @(filter.timeframeInHours);
    return new;
}

@end
