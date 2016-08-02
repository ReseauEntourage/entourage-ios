//
//  OTTourUI.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourUI.h"
#import "OTConsts.h"
#import "NSDate+ui.h"

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

- (NSString *)navigationTitle {
    return OTLocalizedString(@"tour");
}

- (void)timeDataWithCompletion:(void (^)(NSString *))completion {
    completion([NSString stringWithFormat:OTLocalizedString(@"item_time_data"), [self.tour.creationDate sinceNow], self.tour.distance]);
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

@end
