//
//  OTMyEntouragesFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"

@interface OTMyEntouragesFilter : OTFeedItemFilters

@property (nonatomic) BOOL showTours;
@property (nonatomic) BOOL showDemand;
@property (nonatomic) BOOL showContribution;

@property (nonatomic) BOOL isUnread;
@property (nonatomic) BOOL showMyEntouragesOnly;
@property (nonatomic) BOOL showFromOrganisationOnly;
@property (nonatomic) BOOL isIncludingClosed;

@end
