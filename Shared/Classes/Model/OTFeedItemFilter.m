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

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children {
    return [OTFeedItemFilter createFor:key active:active children:children showBoldText:NO];
}

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children
                   showBoldText:(BOOL)showBoldText {
    OTFeedItemFilter *result = [OTFeedItemFilter new];
    result.key = key;
    result.active = active;
    result.title = [OTFeedItemFilter stringForKey:key];
    result.subItems = children;
    result.showBoldText = showBoldText;
    return result;
}
    
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children
                          image:(NSString*)image
                   showBoldText:(BOOL)showBoldText {
    OTFeedItemFilter *result = [OTFeedItemFilter new];
    result.key = key;
    result.active = active;
    result.title = [OTFeedItemFilter stringForKey:key];
    result.subItems = children;
    result.image = image;
    result.showBoldText = showBoldText;
    return result;
}

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                          title:(NSString *)title {
    OTFeedItemFilter *result = [OTFeedItemFilter new];
    result.key = key;
    result.active = active;
    result.title = title;
    return result;
}

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                      withImage:(NSString *)image {
    OTFeedItemFilter *result = [OTFeedItemFilter createFor:key active:active children:@[]];
    result.image = image;
    return result;
}

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                      withImage:(NSString *)image
                          title:(NSString *)title {
    OTFeedItemFilter *result = [OTFeedItemFilter new];
    result.key = key;
    result.active = active;
    result.title = title;
    result.image = image;
    
    return result;
}

#pragma mark - private methods

+ (NSString *)stringForKey:(FeedItemFilterKey)key {
    switch (key) {
        case FeedItemFilterKeyUnread:
            return OTLocalizedString(@"filter_entourage_unread");
        case FeedItemFilterKeyIncludingClosed:
            return OTLocalizedString(@"filter_entourage_include_closed");
            
        case FeedItemFilterKeyDemand:
            return OTLocalizedString(@"demande");
        case FeedItemFilterKeyContribution:
            return OTLocalizedString(@"contribution_filter");
        case FeedItemFilterKeyTour:
            return OTLocalizedString(@"filter_entourage_show_tours");
        case FeedItemFilterKeyMedical:
            return OTLocalizedString(@"filter_maraude_medical");
        case FeedItemFilterKeySocial:
            return OTLocalizedString(@"filter_maraude_bare_hands");
        case FeedItemFilterKeyDistributive:
            return OTLocalizedString(@"filter_maraude_alimentary");
        case FeedItemFilterKeyOrganisation:
            return OTLocalizedString(@"filter_entourage_from_sympathisants");
        case FeedItemFilterKeyMyEntourages:
            return OTLocalizedString(@"filter_entourage_my_entourages");
        case FeedItemFilterKeyMyEntouragesOnly:
            return OTLocalizedString(@"filter_entourage_only_my_entourages");
        case FeedItemFilterKeyMyOrganisationOnly:
            return OTLocalizedString(@"filter_entourage_only_my_organisation");
        
        case FeedItemFilterKeyNeighborhoods:
            return OTLocalizedString(@"pfp_filter_neighborhoods_title");
        case FeedItemFilterKeyPrivateCircles:
            return OTLocalizedString(@"pfp_filter_private_circles_title");
        case FeedItemFilterKeyEvents:
            return [OTAppAppearance eventsFilterTitle];
        case FeedItemFilterKeyEventsPast:
            return [OTAppAppearance includePastEventsFilterTitle];
        case FeedItemFilterKeyAlls:
            return OTLocalizedString(@"filter_all");
            case FeedItemFilterKeyPartners:
            return OTLocalizedString(@"filter_partnersOnly");
        default:
            return @"";
    }
}

@end
