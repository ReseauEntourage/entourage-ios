//
//  OTJoinRequestedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinRequestedCell.h"
#import "OTFeedItemJoiner.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"

// Sergiu : again apologies for magic numbers (i hate ios tables with autolayout)
#define BUTTON_MARGIN 144

@implementation OTJoinRequestedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    CGRect bounds = CGRectMake(0, 0, self.dataSource.tableView.contentSize.width - BUTTON_MARGIN, self.btnLast.bounds.size.height);
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){7.0, 7.0}].CGPath;
    self.btnLast.layer.mask = maskLayer;
    self.btnAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    [self.btnAvatar setupAsProfilePictureFromUrl:joiner.avatarUrl withPlaceholder:@"user"];
    self.lblUserName.text = joiner.displayName;
    self.lblMessage.text = @"";
    if(joiner.message.length > 0)
        self.lblMessage.text = [NSString stringWithFormat:@"\"%@\"", joiner.message];
    NSString *joinType = [joiner.feedItem isKindOfClass:[OTTour class]] ? @"want_to_join_tour" : @"want_to_join_entourage";
    self.lblJoinType.text = OTLocalizedString(joinType);
}

- (IBAction)showUserDetails:(id)sender {
    [Flurry logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemJoiner *joiner = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:joiner.uID];
}

- (IBAction)acceptJoin {
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemJoiner *joiner = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.dataSource acceptJoin:joiner atPath:indexPath];
}

- (IBAction)rejectJoin {
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemJoiner *joiner = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.dataSource rejectJoin:joiner atPath:indexPath];
}

@end
