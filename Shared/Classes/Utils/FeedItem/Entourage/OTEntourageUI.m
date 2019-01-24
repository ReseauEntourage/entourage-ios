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
#import "entourage-Swift.h"

@implementation OTEntourageUI

- (NSAttributedString *)descriptionWithSize:(CGFloat)size {
	return [OTAppAppearance formattedDescriptionForMessageItem:self.entourage size:size isDynamic:NO];
}

- (NSAttributedString *)descriptionWithDynamicSize:(CGFloat)size {
	return [OTAppAppearance formattedDescriptionForMessageItem:self.entourage size:size isDynamic:YES];
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

- (NSAttributedString *)eventAuthorFormattedDescription {
    return [OTAppAppearance formattedAuthorDescriptionForMessageItem:self.entourage];
}

- (NSAttributedString *)eventInfoFormattedDescription {
    
    NSString *prefix = @"rendez-vous";
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSString *startDateInfo = [self.entourage.startsAt asStringWithFormat:@"EEEE dd MMMM"];
    NSString *startTimeInfo = [self.entourage.startsAt toRoundedQuarterTimeString];
    NSString *dateInfo = [NSString stringWithFormat:@"%@ le %@", prefix, startDateInfo];
    NSString *timeInfo = [NSString stringWithFormat:@"\nà %@", startTimeInfo];
    NSString *addressInfo = [NSString stringWithFormat:@"\n%@", self.entourage.displayAddress];
    
    NSString *fullInfoText = [NSString stringWithFormat:@"%@%@%@", dateInfo, timeInfo, addressInfo];
    
    NSMutableAttributedString *infoAttrString = [[NSMutableAttributedString alloc] initWithString:fullInfoText attributes:@{NSFontAttributeName :[UIFont SFUITextWithSize:fontSize type:SFUITextFontTypeBold]}];
    
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
