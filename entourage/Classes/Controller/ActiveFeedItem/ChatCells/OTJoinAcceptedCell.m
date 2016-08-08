//
//  OTJoinAcceptedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinAcceptedCell.h"
#import "OTFeedItemJoiner.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"

@implementation OTJoinAcceptedCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    [self.lblInfo setAttributedText:[self getLabelText:joiner.displayName]];
}

#pragma mark - private methods

- (NSAttributedString *)getLabelText:(NSString *)userName {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName: [UIColor appOrangeColor]}];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:OTLocalizedString(@"join_user_message") attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    return nameInfoAttrString;
}

@end
