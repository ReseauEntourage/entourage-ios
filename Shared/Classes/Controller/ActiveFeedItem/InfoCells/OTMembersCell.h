//
//  OTMembersCell.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemJoiner.h"
#import "OTUserProfileBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTBaseInfoCell.h"

@interface OTMembersCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (weak, nonatomic) IBOutlet UIStackView *rolesStackView;

- (void)configureWith:(OTFeedItemJoiner *)item;

@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_role;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_asso;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_top_margin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_bottom_margin;

@end
