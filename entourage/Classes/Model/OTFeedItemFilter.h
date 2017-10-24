//
//  OTFeedItemFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FeedItemFilterKeyUnread,
    FeedItemFilterKeyIncludingClosed,
    FeedItemFilterKeyDemand,
    FeedItemFilterKeyContribution,
    FeedItemFilterKeyTour,
    FeedItemFilterKeyTimeframe,
    FeedItemFilterKeyMedical,
    FeedItemFilterKeySocial,
    FeedItemFilterKeyDistributive,
    FeedItemFilterKeyOrganisation,
    FeedItemFilterKeyMyEntourages
} FeedItemFilterKey;

@interface OTFeedItemFilter : NSObject

@property (nonatomic) FeedItemFilterKey key;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* image;

+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key active:(BOOL)active;
+ (OTFeedItemFilter *)createFor:(FeedItemFilterKey)key active:(BOOL)active withImage:(NSString *)image;

@end
