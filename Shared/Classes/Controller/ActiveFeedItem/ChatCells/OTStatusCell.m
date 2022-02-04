//
//  OTStatusCell.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTStatusCell.h"
#import "OTFeedItemStatus.h"
#import "OTConsts.h"

@implementation OTStatusCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemStatus *status = (OTFeedItemStatus *)timelinePoint;
    self.lblStatus.text = status.status;
    self.lblDuration.text = [self intervalToString:status.duration];
    self.lblDistance.text = [NSString stringWithFormat:@"%.2f km", status.distance / 1000.0f];
    self.imgStatus.image = [UIImage imageNamed:@"botEntourage"];
    UIImage *statusImage = [self imageForStatus:status];
    if(statusImage)
        self.imgStatus.image = statusImage;
}

- (NSString *)intervalToString:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (UIImage *)imageForStatus:(OTFeedItemStatus *)status {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *snapshotFormat = status.type == OTFeedItemStatusStart ? @SNAPSHOT_START : @SNAPSHOT_STOP;
    NSString *snapshotFilename = [NSString stringWithFormat:snapshotFormat, status.uID.intValue];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:snapshotFilename];
    return [UIImage imageWithContentsOfFile:filePath];
}

@end
