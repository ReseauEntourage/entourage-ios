//
//  OTJoinRejectedCell.m
//  entourage
//
//  Created by sergiu buceac on 11/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinRejectedCell.h"
#import "OTFeedItemJoiner.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "entourage-Swift.h"

@implementation OTJoinRejectedCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    [self.lblInfo setAttributedText:[self getLabelText:joiner.displayName forItem:joiner.feedItem]];
}

#pragma mark - private methods

- (NSAttributedString *)getLabelText:(NSString *)userName forItem:(OTFeedItem *)feedItem {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor}];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:OTLocalizedString(@"user_join_reject") attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    return nameInfoAttrString;
}

@end
