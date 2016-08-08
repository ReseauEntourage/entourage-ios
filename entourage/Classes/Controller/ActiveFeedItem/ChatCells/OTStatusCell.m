//
//  OTStatusCell.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStatusCell.h"
#import "OTFeedItemStatus.h"

@implementation OTStatusCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemStatus *status = (OTFeedItemStatus *)timelinePoint;
    self.lblStatus.text = status.status;
    self.lblDuration.text = [self intervalToString:status.duration];
    self.lblDistance.text = [NSString stringWithFormat:@"%.2f km", status.distance / 1000.0f];
}

- (NSString *)intervalToString:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

@end
