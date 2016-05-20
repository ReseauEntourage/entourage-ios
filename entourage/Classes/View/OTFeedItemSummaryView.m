//
//  OTFeedItemSummaryView.m
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemSummaryView.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "UILabel+entourage.h"

#define FEEDITEM_SUMMAY_TAG 1
#define FEEDITEM_TYPE_BY_NAME_TAG 2
#define FEEDITEM_AVATAR_TAG 3

@implementation OTFeedItemSummaryView

- (void)setupWithFeedItem:(OTFeedItem *)feedItem {
    UILabel *summaryLabel = [self viewWithTag:FEEDITEM_SUMMAY_TAG];
    summaryLabel.text = [feedItem summary];
    
    UILabel *typeByNameLabel = [self viewWithTag:FEEDITEM_TYPE_BY_NAME_TAG];
    typeByNameLabel.attributedText = [feedItem typeByNameAttributedString];

    
    
    
}

@end
