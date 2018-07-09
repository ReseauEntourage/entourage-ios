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
NSString *const kKeyShowMyEntourages = @"showOnlyMyEntourages";
NSString *const kKeyOrganisation = @"showFromOrganisation";

NSString *const kKeyDemandeSocial = @"showDemandeSocial";
NSString *const kKeyDemandeEvent = @"showDemandeEvent";
NSString *const kKeyDemandeHelp = @"showDemandeHelp";
NSString *const kKeyDemandeResource = @"showDemandeResource";
NSString *const kKeyDemandeInfo = @"showDemandeInfo";
NSString *const kKeyDemandeSkill = @"showDemandeSkill";
NSString *const kKeyDemandeOther = @"showDemandeOther";

NSString *const kKeyContributionSocial = @"showContributionSocial";
NSString *const kKeyContributionEvent = @"showContributionEvent";
NSString *const kKeyContributionHelp = @"showContributionHelp";
NSString *const kKeyContributionResource = @"showContributionResource";
NSString *const kKeyContributionInfo = @"showContributionInfo";
NSString *const kKeyContributionSkill = @"showContributionSkill";
NSString *const kKeyContributionOther = @"showContributionOther";

NSString *const kKeyShowOuting = @"showOuting";
NSString *const kKeyShowPrivateCircle = @"showPrivateCircle";
NSString *const kKeyShowNeighborhood = @"showNeighborhood";

@implementation OTSavedFilter

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.showOuting forKey:kKeyShowOuting];
    [encoder encodeObject:self.showPrivateCircle forKey:kKeyShowPrivateCircle];
    [encoder encodeObject:self.showNeighborhood forKey:kKeyShowNeighborhood];
    
    [encoder encodeObject:self.showMedical forKey:kKeyShowMedical];
    [encoder encodeObject:self.showSocial forKey:kKeyShowSocial];
    [encoder encodeObject:self.showDistributive forKey:kKeyShowDistributive];
    [encoder encodeObject:self.showDemand forKey:kKeyShowDemand];
    [encoder encodeObject:self.showContribution forKey:kKeyShowContribution];
    [encoder encodeObject:self.showTours forKey:kKeyShowTours];
    [encoder encodeObject:self.timeframeInHours forKey:kKeyTimeframe];
    [encoder encodeObject:self.showOnlyMyEntourages forKey:kKeyShowMyEntourages];
    
    [encoder encodeObject:self.showDemandeSocial forKey:kKeyDemandeSocial];
    [encoder encodeObject:self.showDemandeEvent forKey:kKeyDemandeEvent];
    [encoder encodeObject:self.showDemandeHelp forKey:kKeyDemandeHelp];
    [encoder encodeObject:self.showDemandeResource forKey:kKeyDemandeResource];
    [encoder encodeObject:self.showDemandeInfo forKey:kKeyDemandeInfo];
    [encoder encodeObject:self.showDemandeSkill forKey:kKeyDemandeSkill];
    [encoder encodeObject:self.showDemandeOther forKey:kKeyDemandeOther];
    
    [encoder encodeObject:self.showContributionSocial forKey:kKeyContributionSocial];
    [encoder encodeObject:self.showContributionEvent forKey:kKeyContributionEvent];
    [encoder encodeObject:self.showContributionHelp forKey:kKeyContributionHelp];
    [encoder encodeObject:self.showContributionResource forKey:kKeyContributionResource];
    [encoder encodeObject:self.showContributionInfo forKey:kKeyContributionInfo];
    [encoder encodeObject:self.showContributionSkill forKey:kKeyContributionSkill];
    [encoder encodeObject:self.showContributionOther forKey:kKeyContributionOther];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        
        self.showOuting = [decoder decodeObjectForKey:kKeyShowOuting];
        self.showNeighborhood = [decoder decodeObjectForKey:kKeyShowNeighborhood];
        self.showPrivateCircle = [decoder decodeObjectForKey:kKeyShowPrivateCircle];
        
        self.showMedical = [decoder decodeObjectForKey:kKeyShowMedical];
        self.showSocial = [decoder decodeObjectForKey:kKeyShowSocial];
        self.showDistributive = [decoder decodeObjectForKey:kKeyShowDistributive];
        self.showDemand = [decoder decodeObjectForKey:kKeyShowDemand];
        self.showContribution = [decoder decodeObjectForKey:kKeyShowContribution];
        self.showTours = [decoder decodeObjectForKey:kKeyShowTours];
        self.timeframeInHours = [decoder decodeObjectForKey:kKeyTimeframe];
        self.showOnlyMyEntourages = [decoder decodeObjectForKey:kKeyShowMyEntourages];
        self.showFromOrganisation = [decoder decodeObjectForKey:kKeyOrganisation];
        
        self.showDemandeSocial = [decoder decodeObjectForKey:kKeyDemandeSocial];
        self.showDemandeEvent = [decoder decodeObjectForKey:kKeyDemandeEvent];
        self.showDemandeHelp = [decoder decodeObjectForKey:kKeyDemandeHelp];
        self.showDemandeResource = [decoder decodeObjectForKey:kKeyDemandeResource];
        self.showDemandeInfo = [decoder decodeObjectForKey:kKeyDemandeInfo];
        self.showDemandeSkill = [decoder decodeObjectForKey:kKeyDemandeSkill];
        self.showDemandeOther = [decoder decodeObjectForKey:kKeyDemandeOther];
        
        self.showContributionSocial = [decoder decodeObjectForKey:kKeyContributionSocial];
        self.showContributionEvent = [decoder decodeObjectForKey:kKeyContributionEvent];
        self.showContributionHelp = [decoder decodeObjectForKey:kKeyContributionHelp];
        self.showContributionResource = [decoder decodeObjectForKey:kKeyContributionResource];
        self.showContributionInfo = [decoder decodeObjectForKey:kKeyContributionInfo];
        self.showContributionSkill = [decoder decodeObjectForKey:kKeyContributionSkill];
        self.showContributionOther = [decoder decodeObjectForKey:kKeyContributionOther];
    }
    return self;
}

+ (OTSavedFilter *)fromNewsFeedsFilter:(OTNewsFeedsFilter *)filter {
    OTSavedFilter *new = [OTSavedFilter new];
    
    new.showNeighborhood = @(filter.showNeighborhood);
    new.showPrivateCircle = @(filter.showPrivateCircle);
    new.showOuting = @(filter.showOuting);
    
    new.showMedical = @(filter.showMedical);
    new.showSocial = @(filter.showSocial);
    new.showDistributive = @(filter.showDistributive);
    new.showDemand = @(filter.showDemand);
    new.showContribution = @(filter.showContribution);
    new.showTours = @(filter.showTours);
    new.timeframeInHours = @(filter.timeframeInHours);
    new.showOnlyMyEntourages = @(filter.showOnlyMyEntourages);
    new.showFromOrganisation = @(filter.showFromOrganisation);
    new.showDemandeSocial = @(filter.showDemandeSocial);
    new.showDemandeEvent =  @(filter.showDemandeEvent);
    new.showDemandeHelp = @(filter.showDemandeHelp);
    new.showDemandeResource = @(filter.showDemandeResource);
    new.showDemandeInfo = @(filter.showDemandeInfo);
    new.showDemandeSkill = @(filter.showDemandeSkill);
    new.showDemandeOther = @(filter.showDemandeOther);
    new.showContributionSocial = @(filter.showContributionSocial);
    new.showContributionEvent = @(filter.showContributionEvent);
    new.showContributionHelp = @(filter.showContributionHelp);
    new.showContributionResource = @(filter.showContributionResource);
    new.showContributionInfo = @(filter.showContributionInfo);
    new.showContributionSkill = @(filter.showContributionSkill);
    new.showContributionOther = @(filter.showContributionOther);
    
    return new;
}

@end
