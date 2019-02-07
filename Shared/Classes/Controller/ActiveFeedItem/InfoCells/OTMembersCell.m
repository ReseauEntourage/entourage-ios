//
//  OTMembersCell.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersCell.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "UIImageView+entourage.h"
#import "OTPillLabelView.h"

@implementation OTMembersCell

- (void)configureWith:(OTFeedItemJoiner *)item {
    self.imgAssociation.hidden = item.partner == nil;
    [self.imgAssociation setupFromUrl:item.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    self.lblDisplayName.text = item.displayName;
    [self.btnProfile setupAsProfilePictureFromUrl:item.avatarUrl];
    
    NSMutableArray<NSString *> *roles = [NSMutableArray new];
    if (item.groupRole != nil) {
        [roles addObject:item.groupRole];
    }
    for (NSString *role in item.communityRoles) {
        if (![role isEqualToString:item.groupRole]) {
            [roles addObject:role];
        }
    }

    [self.rolesStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSString *role in roles) {
        OTRoleTag *tag = [[OTRoleTag alloc] initWithName:role];
        if (tag.visible) {
            UIView *tagView = [OTPillLabelView createWithRoleTag:tag andFontSize:self.lblDisplayName.font.pointSize];
            [self.rolesStackView addArrangedSubview:tagView];
        }
    }
}

@end
