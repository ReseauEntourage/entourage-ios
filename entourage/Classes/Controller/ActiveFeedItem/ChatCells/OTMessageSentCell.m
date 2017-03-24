//
//  OTMessageSentCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageSentCell.h"
#import "OTFeedItemMessage.h"

@implementation OTMessageSentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemMessage *msgData = (OTFeedItemMessage *)timelinePoint;
    self.txtMessage.text = msgData.text;
    self.time.text = [self getTimeString:timelinePoint.date];
}

#pragma mark - private methods

- (NSString *)getTimeString: (NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    return [NSString stringWithFormat:@"%ldh%ld", (long)hour, (long)minute];
}

@end
