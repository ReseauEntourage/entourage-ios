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
    
    //Check to show Role + asso
    if (item.hasToShowRoleAndPartner) {
        [self.ui_label_title_role setHidden:NO];
        [self.ui_button_asso setHidden:NO];
        NSString *roleStr = @"";
        if (item.partner_role_title.length > 0) {
            roleStr = [NSString stringWithFormat:@"%@ -",item.partner_role_title];
        }
        self.ui_label_title_role.text = roleStr;
        
        [self.ui_button_asso setTitle:item.partner.name forState:UIControlStateNormal];
        
        [self.ui_button_asso setTag:item.partner.aid.integerValue];
    }
    else {
        self.ui_constraint_bottom_margin.constant = 0;
        self.ui_constraint_top_margin.constant = 40;
        [self.ui_label_title_role setHidden:YES];
        [self.ui_button_asso setHidden:YES];
    }
    
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
