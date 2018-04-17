//
//  OTSavedMyEntouragesFilter.h
//  entourage
//
//  Created by Mihai Ionescu on 19/12/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTMyEntouragesFilter;

@interface OTSavedMyEntouragesFilter : NSObject<NSCoding>

@property (nonatomic) NSNumber* showTours;
@property (nonatomic) NSNumber* showDemand;
@property (nonatomic) NSNumber* showContribution;

@property (nonatomic) NSNumber* isUnread;
@property (nonatomic) NSNumber* showMyEntouragesOnly;
@property (nonatomic) NSNumber* showFromOrganisationOnly;
@property (nonatomic) NSNumber* isIncludingClosed;

+ (OTSavedMyEntouragesFilter *)fromMyEntouragesFilter:(OTMyEntouragesFilter *)filter;

@end
