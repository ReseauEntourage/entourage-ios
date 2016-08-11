//
//  OTMyEntourageFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntourageFilter.h"
#import "OTConsts.h"

@implementation OTMyEntourageFilter

+ (OTMyEntourageFilter *)createFor:(MyEntourageFilterKey)key active:(BOOL)active {
    OTMyEntourageFilter *result = [OTMyEntourageFilter new];
    result.key = key;
    result.active = active;
    result.title = [OTMyEntourageFilter stringForKey:key];
    return result;
}

- (void)change:(OTMyEntouragesFilter *)filter {
    switch (self.key) {
        case MyEntourageFilterKeyActive:
            filter.isActive = self.active;
            break;
        case MyEntourageFilterKeyInvitation:
            filter.isInvited = self.active;
            break;
        case MyEntourageFilterKeyOrganiser:
            filter.isOrganiser = self.active;
            break;
        case MyEntourageFilterKeyClosed:
            filter.isClosed = self.active;
            break;
        case MyEntourageFilterKeyDemand:
            filter.showDemand = self.active;
            break;
        case MyEntourageFilterKeyContribution:
            filter.showContribution = self.active;
            break;
        case MyEntourageFilterKeyTour:
            filter.showTours = self.active;
            break;
        case MyEntourageFilterKeyOnlyMyEntourages:
            filter.showOnlyMyEntourages = self.active;
            break;
        default:
            break;
    }
}

#pragma mark - private methods

+ (NSString *)stringForKey:(MyEntourageFilterKey)key {
    switch (key) {
        case MyEntourageFilterKeyActive:
            return OTLocalizedString(@"join_active");
        case MyEntourageFilterKeyInvitation:
            return OTLocalizedString(@"invitations");
        case MyEntourageFilterKeyOrganiser:
            return OTLocalizedString(@"organiser");
        case MyEntourageFilterKeyClosed:
            return OTLocalizedString(@"closed");
        case MyEntourageFilterKeyDemand:
            return OTLocalizedString(@"demande");
        case MyEntourageFilterKeyContribution:
            return OTLocalizedString(@"contribution");
        case MyEntourageFilterKeyTour:
            return OTLocalizedString(@"filter_entourage_show_tours");
        case MyEntourageFilterKeyOnlyMyEntourages:
            return OTLocalizedString(@"filter_entourage_only_my_entourages");
        default:
            return @"";
    }
}

@end
