//
//  OTFeedItemFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FeedItemFilterKeyContributionSocial,
    FeedItemFilterKeyContributionHelp,
    FeedItemFilterKeyContributionResource,
    FeedItemFilterKeyContributionOther,
    FeedItemFilterKeyContributionInfo,
    FeedItemFilterKeyContributionSkill,
    
    FeedItemFilterKeyDemandeSocial,
    FeedItemFilterKeyDemandeHelp,
    FeedItemFilterKeyDemandeResource,
    FeedItemFilterKeyDemandeOther,
    FeedItemFilterKeyDemandeInfo,
    FeedItemFilterKeyDemandeSkill,

    FeedItemFilterKeyUnread,
    FeedItemFilterKeyIncludingClosed,
    FeedItemFilterKeyContribution,
    FeedItemFilterKeyDemand,
    FeedItemFilterKeyTour,
    FeedItemFilterKeyTimeframe,
    FeedItemFilterKeyMedical,
    FeedItemFilterKeySocial,
    FeedItemFilterKeyDistributive,
    FeedItemFilterKeyOrganisation,
    FeedItemFilterKeyMyEntourages,
    FeedItemFilterKeyMyEntouragesOnly,
    FeedItemFilterKeyMyOrganisationOnly,

    FeedItemFilterKeyNeighborhoods,
    FeedItemFilterKeyPrivateCircles,
    FeedItemFilterKeyEvents,
    FeedItemFilterKeyEventsPast,
    FeedItemFilterKeyPartners,
    FeedItemFilterKeyAlls,
} FeedItemFilterKey;

@interface OTFeedItemFilter : NSObject

@property (nonatomic) FeedItemFilterKey key;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* image;
@property (nonatomic) BOOL showBoldText;
@property (nonatomic, strong) NSArray<OTFeedItemFilter *> *subItems; 

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children;
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children
                   showBoldText:(BOOL)showBoldText;
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                          title:(NSString *)title;
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                      withImage:(NSString *)image;
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                      withImage:(NSString *)image
                          title:(NSString *)title;
    
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key
                         active:(BOOL)active
                       children:(NSArray *)children
                          image:(NSString*)image
                   showBoldText:(BOOL)showBoldText;

@end
