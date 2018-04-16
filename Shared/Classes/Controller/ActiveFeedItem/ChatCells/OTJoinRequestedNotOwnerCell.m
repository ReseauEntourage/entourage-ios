//
//  OTJoinRequestedNotOwnerCell.m
//  entourage
//
//  Created by sergiu buceac on 11/1/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinRequestedNotOwnerCell.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "UIImageView+entourage.h"
#import "OTConsts.h"

#define BUTTON_MARGIN 144

@implementation OTJoinRequestedNotOwnerCell

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
    self.imgAssociation.hidden = joiner.partner == nil;
    [self.imgAssociation setupFromUrl:joiner.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    [self.btnAvatar setupAsProfilePictureFromUrl:joiner.avatarUrl withPlaceholder:@"user"];
    self.lblUserName.text = joiner.displayName;
    self.lblMessage.text = @"";
    if(joiner.message.length > 0)
        self.lblMessage.text = [NSString stringWithFormat:@"\"%@\"", joiner.message];
    NSString *joinType = [joiner.feedItem isKindOfClass:[OTTour class]] ? @"want_to_join_tour" : @"want_to_join_entourage";
    self.lblJoinType.text = OTLocalizedString(joinType);
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemJoiner *joiner = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:joiner.uID];
}

@end
