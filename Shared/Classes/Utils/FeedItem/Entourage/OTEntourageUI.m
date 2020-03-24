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

- (NSAttributedString *)descriptionWithSize:(CGFloat)size {
    return [OTAppAppearance formattedDescriptionForMessageItem:self.entourage size:size];
}

- (NSString *)descriptionWithoutUserName {
    return [OTAppAppearance descriptionForMessageItem:self.entourage];
}

- (NSString *)userName {
    return self.entourage.author.displayName;
}

- (NSString *)summary {
    return self.entourage.title;
}

- (NSString *)categoryIconSource {
    return [OTAppAppearance iconNameForEntourageItem:self.entourage];
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
    
    NSString *prefix = @"rendez-vous";

    NSString *startDateInfo = [self.entourage.startsAt asStringWithFormat:@"EEEE dd MMMM"];
    NSString *startTimeInfo = [self.entourage.startsAt toRoundedQuarterTimeString];
    NSString *dateInfo = [NSString stringWithFormat:@"%@ le %@", prefix, startDateInfo];
    NSString *timeInfo = [NSString stringWithFormat:@"\nà %@", startTimeInfo];
    NSString *addressInfo = [NSString stringWithFormat:@"\n%@", self.entourage.displayAddress];

    NSString *fullInfoText = [NSString stringWithFormat:@"%@%@%@", dateInfo, timeInfo, addressInfo];
    
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
