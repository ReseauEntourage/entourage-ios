//
//  OTChatDateCell.m
//  entourage
//
//  Created by veronica.gliga on 23/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTChatDateCell.h"
#import "OTConsts.h"

@implementation OTChatDateCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    self.lblInfo.text = [self getDateString:timelinePoint.date];
}

#pragma mark - private methods

- (NSString *)getDateString: (NSDate *) date {
    if([[NSCalendar currentCalendar] isDateInToday:date])
        return OTLocalizedString(@"today").uppercaseString;
    if([[NSCalendar currentCalendar] isDateInYesterday:date])
        return OTLocalizedString(@"yesterday").uppercaseString;

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSString *month_string = [NSString stringWithFormat:@"month_%ld", (long)month];
    return [NSString stringWithFormat:@"%ld %@ %ld", (long)day, OTLocalizedString(month_string).uppercaseString, (long) year] ;
}

@end
