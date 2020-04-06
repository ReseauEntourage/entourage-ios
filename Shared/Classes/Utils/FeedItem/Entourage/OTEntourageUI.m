//
//  OTEntourageUI.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageUI.h"
#import "OTConsts.h"
#import "OTLocationManager.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "NSDate+OTFormatter.h"

@implementation OTEntourageUI

- (NSAttributedString *)descriptionWithSize:(CGFloat)size hasToShowDate:(BOOL)isShowDate {
    return [OTAppAppearance formattedDescriptionForMessageItem:self.entourage size:size hasToShowDate:isShowDate];
}

- (NSString *)descriptionWithoutUserName_hasToShowDate:(BOOL)isShowDate {
    NSLog(@"Description without username : %@",self.entourage.startsAt);
    return [OTAppAppearance descriptionForMessageItem:self.entourage hasToShowDate:isShowDate];
}

- (NSString *)userName {
    return self.entourage.author.displayName;
}

- (NSString *)summary {
    return self.entourage.title;
}

- (NSString *)categoryIconSource {
    return [OTAppAppearance iconNameForEntourageItem:self.entourage isAnnotation:NO];
}

- (NSString *)feedItemDescription {
    return self.entourage.desc;
}

- (NSString *)formattedDaysIntervalFromToday:(NSDate *)date {
    if ([[NSCalendar currentCalendar] isDateInToday:date])
        return OTLocalizedString(@"today");
    if ([[NSCalendar currentCalendar] isDateInYesterday:date])
        return OTLocalizedString(@"yesterday");

    NSInteger days = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:[NSDate date] options:0].day;
    if (days < 15) {
        NSString *daysString = [NSString stringWithFormat:@"%ld %@", days, OTLocalizedString(@"days")];
        return [NSString stringWithFormat:OTLocalizedString(@"formatter_time_ago"), daysString];
    }
    if (days <= 30)
        return OTLocalizedString(@"this_month");

    NSInteger months = (days / 30.0) + 0.5;
    NSString *monthsString = [NSString stringWithFormat:@"%ld %@", months, OTLocalizedString(@"months")];
    return [NSString stringWithFormat:OTLocalizedString(@"formatter_time_ago"), monthsString];
}

- (NSString *)formattedTimestamps {
    NSString *creationDate = [self formattedDaysIntervalFromToday:self.entourage.creationDate];
    creationDate = [NSString stringWithFormat:@"%@ %@", OTLocalizedString(@"group_timestamps_created_at"), creationDate];

    if ([[NSCalendar currentCalendar] isDateInToday:self.entourage.creationDate]) {
        return creationDate;
    }
    
    NSString *updatedDate = [self formattedDaysIntervalFromToday:self.entourage.updatedDate];
    updatedDate = [NSString stringWithFormat:@"%@ %@", OTLocalizedString(@"group_timestamps_updated_at"), updatedDate];

    return [@[creationDate, updatedDate] componentsJoinedByString:OTLocalizedString(@"group_timestamps_separator")];
}

- (NSAttributedString *)eventAuthorFormattedDescription {
    return [OTAppAppearance formattedAuthorDescriptionForMessageItem:self.entourage];
}

- (NSString *)eventInfoDescription {
    
    NSString *startDateInfo = [self.entourage.startsAt asStringWithFormat:@"EEEE dd MMMM YYYY"];
    NSString *startTimeInfo = [self.entourage.startsAt toRoundedQuarterTimeString];
    
    NSString *endDateInfo = [self.entourage.endsAt asStringWithFormat:@"EEEE dd MMMM YYYY"];
    NSString *endTimeInfo = [self.entourage.endsAt toRoundedQuarterTimeString];
    
    NSString *dateInfo = OTLocalizedString(@"rendez-vous");
    
    if ([[NSCalendar currentCalendar] isDate:self.entourage.startsAt inSameDayAsDate:self.entourage.endsAt]) {
        dateInfo = [NSString stringWithFormat:@"%@ %@", dateInfo, [NSString stringWithFormat:OTLocalizedString(@"le_"),startDateInfo]];
        NSString *_dateStr = [NSString stringWithFormat:OTLocalizedString(@"de_a"), startTimeInfo,endTimeInfo];
        dateInfo = [NSString stringWithFormat:@"%@\n%@",dateInfo, _dateStr];
    }
    else {
        NSString *_dateStartStr = [NSString stringWithFormat:OTLocalizedString(@"du_a"), startDateInfo,startTimeInfo];
        NSString *_dateEndStr = [NSString stringWithFormat:OTLocalizedString(@"au_a"), endDateInfo,endTimeInfo];
        dateInfo = [NSString stringWithFormat:@"%@ %@ %@",dateInfo,_dateStartStr,_dateEndStr];
    }
    
    NSString *addressInfo = [NSString stringWithFormat:@"\n%@", self.entourage.displayAddress];

    NSString *fullInfoText = [NSString stringWithFormat:@"%@%@", dateInfo, addressInfo];
    
    return fullInfoText;
}

- (NSAttributedString *)eventInfoFormattedDescription {
    
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSString *fullInfoText = [self eventInfoDescription];
    
    NSMutableAttributedString *infoAttrString = [[NSMutableAttributedString alloc] initWithString:fullInfoText attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SFUIText-Bold" size:fontSize]}];
    
    return infoAttrString;
}

- (NSString *)navigationTitle {
    return self.entourage.title;
}

- (NSString *)joinAcceptedText {
    return OTLocalizedString(@"user_joined_entourage");
}

- (double)distance {
    if (!self.entourage.location) {
        return -1;
    }

    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if (!currentLocation) {
        return -1;
    }
    
    return [currentLocation distanceFromLocation:self.entourage.location];
}

- (NSString *)displayType {
    return OTLocalizedString(self.entourage.type);
}

- (BOOL)isStatusBtnVisible {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue])
        return [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN];
    else
        return [self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED] && [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN];
    return NO;
}
@end
