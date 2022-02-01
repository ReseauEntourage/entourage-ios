//
//  OTJoinRequestedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTJoinRequestedCell.h"
#import "OTFeedItemJoiner.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"
#import "UIImageView+entourage.h"
#import "entourage-Swift.h"

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
    
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    [self.btnAccept setTitleColor:color forState:UIControlStateNormal];
    [self.btnIgnore setTitleColor:color forState:UIControlStateNormal];
    [self.btnViewProfile setTitleColor:color forState:UIControlStateNormal];
    
    self.imgAppLogo.image = [OTAppAppearance applicationLogo];
    self.lblAppName.text = [OTAppAppearance applicationTitle];
    self.bgView.backgroundColor = color;
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)timelinePoint;
    self.imgAssociation.hidden = joiner.partner == nil;
    [self.imgAssociation setupFromUrl:joiner.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    [self.btnAvatar setupAsProfilePictureFromUrl:joiner.avatarUrl withPlaceholder:@"user"];
    self.lblUserName.text = joiner.displayName;
    self.lblMessage.text = @"";
    
    if (joiner.message.length > 0) {
        self.lblMessage.text = [NSString stringWithFormat:@"\"%@\"", joiner.message];
    }
    
    self.lblJoinType.text = [OTAppAppearance requestToJoinTitleForFeedItem:joiner.feedItem];
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
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
