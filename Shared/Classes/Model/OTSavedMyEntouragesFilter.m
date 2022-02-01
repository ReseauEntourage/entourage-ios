//
//  OTSavedMyEntouragesFilter.m
//  entourage
//
//  Created by Mihai Ionescu on 19/12/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

// TO-DO Find a better way to store filters

#import "OTSavedMyEntouragesFilter.h"
#import "OTMyEntouragesFilter.h"

NSString *const kKeyMyEntouragesShowTours = @"showTours";
NSString *const kKeyMyEntouragesShowDemand = @"showDemand";
NSString *const kKeyMyEntouragesShowContribution = @"showContribution";

NSString *const kKeyMyEntouragesShowUnread = @"showUnread";
NSString *const kKeyMyEntouragesShowMyEntouragesOnly = @"showMyEntouragesOnly";
NSString *const kKeyMyEntouragesShowFromOrganisationOnly = @"showFromOrganisationOnly";
NSString *const kKeyMyEntouragesShowIncludingClosed = @"showIncludingClosed";

@implementation OTSavedMyEntouragesFilter

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.showTours forKey:kKeyMyEntouragesShowTours];
    [encoder encodeObject:self.showDemand forKey:kKeyMyEntouragesShowDemand];
    [encoder encodeObject:self.showContribution forKey:kKeyMyEntouragesShowContribution];
    
    [encoder encodeObject:self.isUnread forKey:kKeyMyEntouragesShowUnread];
    [encoder encodeObject:self.showMyEntouragesOnly forKey:kKeyMyEntouragesShowMyEntouragesOnly];
    [encoder encodeObject:self.showFromOrganisationOnly forKey:kKeyMyEntouragesShowFromOrganisationOnly];
    [encoder encodeObject:self.isIncludingClosed forKey:kKeyMyEntouragesShowIncludingClosed];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]) != nil) {
        self.showTours = [decoder decodeObjectForKey:kKeyMyEntouragesShowTours];
        self.showDemand = [decoder decodeObjectForKey:kKeyMyEntouragesShowDemand];
        self.showContribution = [decoder decodeObjectForKey:kKeyMyEntouragesShowContribution];
        
        self.isUnread = [decoder decodeObjectForKey:kKeyMyEntouragesShowUnread];
        self.showMyEntouragesOnly = [decoder decodeObjectForKey:kKeyMyEntouragesShowMyEntouragesOnly];
        self.showFromOrganisationOnly = [decoder decodeObjectForKey:kKeyMyEntouragesShowFromOrganisationOnly];
        self.isIncludingClosed = [decoder decodeObjectForKey:kKeyMyEntouragesShowIncludingClosed];
    }
    return self;
}

+ (OTSavedMyEntouragesFilter *)fromMyEntouragesFilter:(OTMyEntouragesFilter *)filter {
    OTSavedMyEntouragesFilter *savedFilter = [OTSavedMyEntouragesFilter new];
    
    savedFilter.showTours = @(filter.showTours);
    savedFilter.showDemand = @(filter.showDemand);
    savedFilter.showContribution = @(filter.showContribution);
    
    savedFilter.isUnread = @(filter.isUnread);
    savedFilter.showMyEntouragesOnly = @(filter.showMyEntouragesOnly);
    savedFilter.showFromOrganisationOnly = @(filter.showFromOrganisationOnly);
    savedFilter.isIncludingClosed = @(filter.isIncludingClosed);
    
    return savedFilter;
}

@end
