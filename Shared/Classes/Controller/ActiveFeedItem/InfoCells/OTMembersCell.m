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
#import "entourage-Swift.h"

@implementation OTMembersCell

- (void)configureWith:(OTFeedItemJoiner *)item {
    self.imgAssociation.hidden = item.partner == nil;
    [self.imgAssociation setupFromUrl:item.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    self.lblDisplayName.text = item.displayName;
    
    //Check to show Role + asso
    if (item.hasToShowRoleAndPartner) {
        [self.ui_label_title_role setHidden:NO];
        [self.ui_button_asso setHidden:NO];
        [self.ui_label_asso setHidden:NO];
        NSString *roleStr = @"";
        if (item.partner_role_title.length > 0) {
            roleStr = [NSString stringWithFormat:@"%@ -",item.partner_role_title];
        }
        self.ui_label_title_role.text = roleStr;
        
        NSString *keyJoined = @"info_asso_user";
        if (item.isPartnerWithCurrentUser) {
            keyJoined = @"info_asso_user_joined";
        }
        
        
        NSString *titleButton = [NSString stringWithFormat:@"%@ %@",item.partner.name,[OTLocalisationService getLocalizedValueForKey:keyJoined]];
        NSString *coloredStr = [OTLocalisationService getLocalizedValueForKey:keyJoined];
        NSAttributedString *attrStr = [Utilitaires formatStringWithStringMessage:titleButton coloredTxt:coloredStr color:[UIColor appOrangeColor] colorHighlight:[UIColor appOrangeColor] fontSize:15 fontWeight:UIFontWeightMedium fontColoredWeight:UIFontWeightBold];
        
        self.ui_label_asso.attributedText = attrStr;
        
        [self.ui_button_asso setTag:item.partner.aid.integerValue];
    }
    else {
        self.ui_constraint_bottom_margin.constant = 0;
        self.ui_constraint_top_margin.constant = 40;
        [self.ui_label_title_role setHidden:YES];
        [self.ui_button_asso setHidden:YES];
        [self.ui_label_asso setHidden:YES];
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
