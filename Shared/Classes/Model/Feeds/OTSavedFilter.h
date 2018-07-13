//
//  OTSavedFilter.h
//  entourage
//
//  Created by sergiu.buceac on 10/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OTNewsFeedsFilter;

@interface OTSavedFilter : NSObject<NSCoding>

@property (nonatomic) NSNumber *showMedical;
@property (nonatomic) NSNumber *showSocial;
@property (nonatomic) NSNumber *showDistributive;
@property (nonatomic) NSNumber *showDemand;
@property (nonatomic) NSNumber *showContribution;
@property (nonatomic) NSNumber *showTours;
@property (nonatomic) NSNumber *timeframeInHours;
@property (nonatomic) NSNumber *showOnlyMyEntourages;
@property (nonatomic) NSNumber *showFromOrganisation;

@property (nonatomic) NSNumber *showOuting;
@property (nonatomic) NSNumber *showPastOuting;
@property (nonatomic) NSNumber *showNeighborhood;
@property (nonatomic) NSNumber *showPrivateCircle;

@property (nonatomic) NSNumber *showDemandeSocial;
@property (nonatomic) NSNumber *showDemandeEvent;
@property (nonatomic) NSNumber *showDemandeHelp;
@property (nonatomic) NSNumber *showDemandeResource;
@property (nonatomic) NSNumber *showDemandeInfo;
@property (nonatomic) NSNumber *showDemandeSkill;
@property (nonatomic) NSNumber *showDemandeOther;

@property (nonatomic) NSNumber *showContributionSocial;
@property (nonatomic) NSNumber *showContributionEvent;
@property (nonatomic) NSNumber *showContributionHelp;
@property (nonatomic) NSNumber *showContributionResource;
@property (nonatomic) NSNumber *showContributionInfo;
@property (nonatomic) NSNumber *showContributionSkill;
@property (nonatomic) NSNumber *showContributionOther;

+ (OTSavedFilter *)fromNewsFeedsFilter:(OTNewsFeedsFilter *)filter;

@end
