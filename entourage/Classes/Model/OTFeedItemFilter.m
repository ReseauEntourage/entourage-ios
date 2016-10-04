//
//  OTFeedItemFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemFilter.h"
#import "OTConsts.h"

@implementation OTFeedItemFilter

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key active:(BOOL)active {
    OTFeedItemFilter *result = [OTFeedItemFilter new];
    result.key = key;
    result.active = active;
    result.title = [OTFeedItemFilter stringForKey:key];
    return result;
}

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key active:(BOOL)active withImage:(NSString *)image {
    OTFeedItemFilter *result = [OTFeedItemFilter createFor:key active:active];
    result.image = image;
    return result;
}

#pragma mark - private methods

+ (NSString *)stringForKey:(FeedItemFilterKey)key {
    switch (key) {
        case FeedItemFilterKeyActive:
            return OTLocalizedString(@"join_active");
        case FeedItemFilterKeyInvitation:
            return OTLocalizedString(@"invitations");
        case FeedItemFilterKeyOrganiser:
            return OTLocalizedString(@"created_by_me_unique");
        case FeedItemFilterKeyClosed:
            return OTLocalizedString(@"closed");
        case FeedItemFilterKeyDemand:
            return OTLocalizedString(@"demande");
        case FeedItemFilterKeyContribution:
            return OTLocalizedString(@"contribution");
        case FeedItemFilterKeyTour:
            return OTLocalizedString(@"filter_entourage_show_tours");
        case FeedItemFilterKeyOnlyMyEntourages:
            return OTLocalizedString(@"filter_entourage_only_my_entourages");
        case FeedItemFilterKeyMedical:
            return OTLocalizedString(@"filter_maraude_medical");
        case FeedItemFilterKeySocial:
            return OTLocalizedString(@"filter_maraude_bare_hands");
        case FeedItemFilterKeyDistributive:
            return OTLocalizedString(@"filter_maraude_alimentary");
        default:
            return @"";
    }
}

@end
