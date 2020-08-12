//
//  OTNewsFeedsFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"
#import <MapKit/MapKit.h>

@interface OTNewsFeedsFilter : OTFeedItemFilters<NSCopying>

@property (nonatomic, assign) BOOL isPro;
@property (nonatomic) BOOL showMedical;
@property (nonatomic) BOOL showSocial;
@property (nonatomic) BOOL showDistributive;
@property (nonatomic) BOOL showDemand;
@property (nonatomic) BOOL showContribution;
@property (nonatomic) BOOL showTours;

@property (nonatomic) BOOL showOuting;
@property (nonatomic) BOOL showPastOuting;
@property (nonatomic) BOOL showNeighborhood;
@property (nonatomic) BOOL showPrivateCircle;

@property (nonatomic) BOOL showOnlyMyEntourages;
@property (nonatomic) BOOL showFromOrganisation;

@property (nonatomic) BOOL showDemandeSocial;
@property (nonatomic) BOOL showDemandeHelp;
@property (nonatomic) BOOL showDemandeResource;
@property (nonatomic) BOOL showDemandeInfo;
@property (nonatomic) BOOL showDemandeSkill;
@property (nonatomic) BOOL showDemandeOther;

@property (nonatomic) BOOL showContributionSocial;
@property (nonatomic) BOOL showContributionHelp;
@property (nonatomic) BOOL showContributionResource;
@property (nonatomic) BOOL showContributionInfo;
@property (nonatomic) BOOL showContributionSkill;
@property (nonatomic) BOOL showContributionOther;

@property (nonatomic) int timeframeInHours;
@property (nonatomic) int distance;
@property (nonatomic) CLLocationCoordinate2D location;

- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before andLocation:(CLLocationCoordinate2D)location;
- (NSMutableDictionary *)toDictionaryWithPageToken:(NSString *)pageToken andLocation:(CLLocationCoordinate2D)location;
- (void)changeFiltersForProOnly;

-(void)setNeighbourFilters;
-(void)setAloneFilters;
-(BOOL) isDefaultFilters;
-(BOOL) isDefaultEncounterFilters;

@property (nonatomic) BOOL isEncouterFilter;
@property (nonatomic) BOOL showPartners;
@property (nonatomic) BOOL showAlls;
@end
