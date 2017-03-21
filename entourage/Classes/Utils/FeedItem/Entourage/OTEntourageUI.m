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

@implementation OTEntourageUI

- (NSAttributedString *)descriptionWithSize:(CGFloat)size {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formater_by"), OTLocalizedString(self.entourage.type).capitalizedString] attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.entourage.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_BOLD_DESCRIPTION size:size]}];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    return typeByNameAttrString;
}

- (NSString *)summary {
    return self.entourage.title;
}

- (NSString *)feedItemDescription {
    return self.entourage.desc;
}

- (NSString *)navigationTitle {
    return OTLocalizedString([self displayType]);
}

- (NSString *)joinAcceptedText {
    return OTLocalizedString(@"user_joined_entourage");
}

- (double)distance {
    if(!self.entourage.location)
        return -1;

    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if(!currentLocation)
        return -1;
    
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
        return [self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED];
    return NO;
}

@end
