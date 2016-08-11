//
//  OTMyEntourageFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTMyEntouragesFilter.h"

typedef enum {
    MyEntourageFilterKeyActive,
    MyEntourageFilterKeyInvitation,
    MyEntourageFilterKeyOrganiser,
    MyEntourageFilterKeyClosed,
    MyEntourageFilterKeyDemand,
    MyEntourageFilterKeyContribution,
    MyEntourageFilterKeyTour
} MyEntourageFilterKey;

@interface OTMyEntourageFilter : NSObject

@property (nonatomic) MyEntourageFilterKey key;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString* title;

+ (OTMyEntourageFilter *)createFor:(MyEntourageFilterKey)key active:(BOOL)active;
- (void)change:(OTMyEntouragesFilter *)filter;

@end
