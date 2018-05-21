//
//  OTJoinAcceptedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinAcceptedCell.h"
#import "OTFeedItemJoiner.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "entourage-Swift.h"

@implementation OTJoinAcceptedCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    [self.lblInfo setAttributedText:[self getLabelText:joiner.displayName forItem:joiner.feedItem]];
}

#pragma mark - private methods

- (NSAttributedString *)getLabelText:(NSString *)userName forItem:(OTFeedItem *)feedItem {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor}];
    NSString *joinText = [[[OTFeedItemFactory createFor:feedItem] getUI] joinAcceptedText];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:joinText attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    return nameInfoAttrString;
}

@end
