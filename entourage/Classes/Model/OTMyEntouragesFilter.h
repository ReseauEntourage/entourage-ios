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

@property (nonatomic) BOOL isUnread;
@property (nonatomic) BOOL isIncludingClosed;
@property (nonatomic) BOOL showDemand;
@property (nonatomic) BOOL showContribution;
@property (nonatomic) BOOL showTours;
@property (nonatomic) BOOL showMyEntourages;
@property (nonatomic) BOOL showFromOrganisation;

@end
