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
@property (nonatomic) BOOL showOnlyMyEntourages;
@property (nonatomic) BOOL showFromOrganisation;
@property (nonatomic) int timeframeInHours;
@property (nonatomic) int distance;
@property (nonatomic) CLLocationCoordinate2D location;

- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before andLocation:(CLLocationCoordinate2D)location;

@end
