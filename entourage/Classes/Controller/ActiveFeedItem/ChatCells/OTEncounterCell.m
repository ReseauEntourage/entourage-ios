//
//  OTEncounterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEncounterCell.h"
#import "OTEncounter.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"

@implementation OTEncounterCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTEncounter *encounter = (OTEncounter *)timelinePoint;
    [self.btnInfo setAttributedTitle:[self getLabelTextForUser:encounter.userName withStreetPersonName:encounter.streetPersonName] forState:UIControlStateNormal];
}

#pragma mark - private methods

- (NSAttributedString *)getLabelTextForUser:(NSString *)userName withStreetPersonName:(NSString *)streetPersonName {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName: [UIColor appOrangeColor]}];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formatter_encounter_and_user_meet"), streetPersonName] attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    return nameInfoAttrString;
}

@end
