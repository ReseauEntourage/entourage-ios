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

+ (OTSavedFilter *)fromNewsFeedsFilter:(OTNewsFeedsFilter *)filter;

@end
