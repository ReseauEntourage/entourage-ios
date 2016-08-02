//
//  OTSummaryProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSummaryProviderBehavior.h"
#import "UIButton+entourage.h"
#import "OTFeedItemFactory.h"

@implementation OTSummaryProviderBehavior

- (void)awakeFromNib {
    if(!self.fontSize)
        self.fontSize = [NSNumber numberWithFloat:15];
}

- (void)configureWith:(OTFeedItem *)feedItem {
    self.lblTitle.text = feedItem.summary;
    self.lblUserCount.text = [feedItem.noPeople stringValue];
    [self.btnAvatar setupAsProfilePictureFromUrl:feedItem.author.avatarUrl];
    [self.lblDescription setAttributedText:[[[OTFeedItemFactory createFor:feedItem] getUI] descriptionWithSize:self.fontSize.floatValue]];
}

@end