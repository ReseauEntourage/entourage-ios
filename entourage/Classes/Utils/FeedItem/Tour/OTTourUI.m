//
//  OTTourUI.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourUI.h"
#import "OTConsts.h"
#import "OTLocationManager.h"
#import "OTTourPoint.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

@implementation OTTourUI

- (NSAttributedString *) descriptionWithSize:(CGFloat)size {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formatter_tour_by"), [self displayType]] attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.tour.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_BOLD_DESCRIPTION size:size]}];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    return typeByNameAttrString;
}

- (NSString *)summary {
    return self.tour.organizationName;
}

- (NSString *)feedItemDescription {
    return @"";
}

- (NSString *)categoryIconSource {
    NSString *source;
    if ([self.tour.type isEqualToString:@"barehands"]) {
        source = @"social_tour_icon";
    } else if ([self.tour.type isEqualToString:@"medical"]) {
        source = @"medical_tour_icon";
    } else if ([self.tour.type isEqualToString:@"alimentary"]) {
        source = @"distributive_tour_icon";
    }
    return source;
}

- (NSString *)navigationTitle {
    return OTLocalizedString(@"tour");
}

- (NSString *)joinAcceptedText {
    return OTLocalizedString(@"user_joined_tour");
}

- (double)distance {
    if(self.tour.tourPoints.count == 0)
        return -1;
    
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if(!currentLocation)
        return -1;
    
    OTTourPoint *first = self.tour.tourPoints[0];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:first.latitude longitude:first.longitude];
    return [currentLocation distanceFromLocation:location];
}

- (NSString *)displayType {
    NSString *tourType;
    if ([self.tour.type isEqualToString:@"barehands"]) {
        tourType = OTLocalizedString(@"tour_type_display_social");
    } else if ([self.tour.type isEqualToString:@"medical"]) {
        tourType = OTLocalizedString(@"tour_type_display_medical");
    } else if ([self.tour.type isEqualToString:@"alimentary"]) {
        tourType = OTLocalizedString(@"tour_type_display_distributive");
    }
    return tourType;
}

- (BOOL)isStatusBtnVisible {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue])
        return [self.tour.status isEqualToString:FEEDITEM_STATUS_CLOSED] || [self.tour.status isEqualToString:TOUR_STATUS_ONGOING];
    else
        return [self.tour.joinStatus isEqualToString:JOIN_ACCEPTED];
    return NO;
}

@end
