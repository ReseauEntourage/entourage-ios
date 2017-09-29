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
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"
#import "OTOngoingTourService.h"
#import "OTTour.h"
#import "OTUser.h"

@interface OTEncounterCell ()

@property (nonatomic, strong) OTEncounter *encounter;

@end

@implementation OTEncounterCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint  {
    self.encounter =  (OTEncounter *)timelinePoint;
    if([self canEditEncounter]) {
        [self.btnInfo setHidden:NO];
        [self.btnInfo setAttributedTitle:[self getLabelTextForUser:self.encounter.userName withStreetPersonName:self.encounter.streetPersonName] forState:UIControlStateNormal];
    }
    else
        [self.btnInfo setHidden:YES];
   [self.btnInfo setEnabled: [self canEditEncounter]];
}

- (void)doEditEncounter {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.encounter.latitude, self.encounter.longitude);
    [self.editEncounter doEdit:self.encounter forTour:self.encounter.tID andLocation: location];
}

#pragma mark - private methods

- (NSAttributedString *)getLabelTextForUser:(NSString *)userName withStreetPersonName:(NSString *)streetPersonName {
    NSMutableAttributedString *nameAttrString = [[NSMutableAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName: [UIColor appOrangeColor]}];
    NSMutableAttributedString *infoAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formatter_encounter_and_user_meet"), streetPersonName] attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    
    if ([self canEditEncounter]) {
       [nameAttrString addAttribute: NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range: NSMakeRange(0, [nameAttrString length])];
        [infoAttrString addAttribute: NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range: NSMakeRange(0, [infoAttrString length])];
    }
    [nameAttrString appendAttributedString:infoAttrString];
    return nameAttrString;
}

// An encounter can be edited only if the tour is ongoing and only by the tour author
- (BOOL) canEditEncounter {
    if ([self.feedItem.status isEqualToString:TOUR_STATUS_ONGOING]) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        OTFeedItemAuthor *author = self.feedItem.author;
        if (currentUser != nil && author != nil) {
            return [currentUser.sid isEqualToNumber:author.uID];
        }
    }
    return NO;
}

@end
