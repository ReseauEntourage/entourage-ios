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
    NSString *authorText = [NSString stringWithFormat:@"\nOrganisé par %@", self.entourage.author.displayName];
    NSMutableAttributedString *authorAttributedText = [[NSMutableAttributedString alloc] initWithString:authorText];
    
    return authorAttributedText;
}

- (NSString *)navigationTitle {
    return self.entourage.title;
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
        return [self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED] && [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN];
    return NO;
}
@end
