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
    
    UIColor *textColor = [OTAppAppearance iconColorForFeedItem:self.entourage];
    NSString *organizerText = @"\nOrganisé";
    NSString *fontName = @"SFUIText-Medium";
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSDictionary *atttributtes = @{NSFontAttributeName :
                                       [UIFont fontWithName:fontName size:fontSize],
                            NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *organizerAttributedText = [[NSMutableAttributedString alloc] initWithString:organizerText attributes:atttributtes];
    
    NSAttributedString *byAttrString = [[NSAttributedString alloc] initWithString: OTLocalizedString(@"by") attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.entourage.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSMutableAttributedString *orgByNameAttrString = organizerAttributedText.mutableCopy;
    [orgByNameAttrString appendAttributedString:byAttrString];
    [orgByNameAttrString appendAttributedString:nameAttrString];

    return orgByNameAttrString;
}

- (NSAttributedString *)eventInfoFormattedDescription {
    
    NSString *prefix = @"rendez-vous";
    NSString *fontName = @"SFUIText-Medium";
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSString *startDateInfo = [self.entourage.startsAt asStringWithFormat:@"EEEE dd MMMM yyyy"];
    NSString *dateInfo = [NSString stringWithFormat:@"%@ %@", prefix, startDateInfo];
    NSString *addressInfo = [NSString stringWithFormat:@"\n%@", self.entourage.displayAddress];
    
    NSMutableAttributedString *infoAttrString = [[NSMutableAttributedString alloc] initWithString:dateInfo attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSAttributedString *addressAttrString = [[NSAttributedString alloc] initWithString:addressInfo attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SFUIText-Bold" size:fontSize]}];
    
    [infoAttrString appendAttributedString:addressAttrString];
    
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
