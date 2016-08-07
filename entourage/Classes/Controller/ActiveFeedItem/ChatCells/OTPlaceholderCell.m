//
//  OTPlaceholderCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPlaceholderCell.h"

@implementation OTPlaceholderCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    self.textLabel.text = [NSString stringWithFormat:@"%@", timelinePoint.date];
}

@end
