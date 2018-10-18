//
//  OTFeedClosedCell.m
//  entourage
//
//  Created by Smart Care on 04/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTFeedClosedCell.h"

@implementation OTFeedClosedCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    self.messageLabel.attributedText = [OTAppAppearance closedFeedChatItemMessageFormattedText:(OTFeedItemMessage*)timelinePoint];
}

@end
