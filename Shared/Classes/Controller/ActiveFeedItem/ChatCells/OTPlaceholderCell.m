//
//  OTPlaceholderCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTPlaceholderCell.h"

@implementation OTPlaceholderCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    self.textLabel.text = OTLocalizedString(@"Invalid");
}

@end
