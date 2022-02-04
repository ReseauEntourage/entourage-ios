//
//  OTMessageReceivedCell.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTMessageDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"

@interface OTMessageReceivedCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet UITextView *txtMessage;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (nonatomic, weak) IBOutlet OTMessageDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfile;
@property (nonatomic, weak) IBOutlet UILabel *time;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_width_iv_link;
@property(nonatomic) BOOL isPOI;
@property(nonatomic) NSNumber *poiId;
@property(nonatomic) CGFloat widthPicto;
@property(nonatomic) NSNumber *userMessageUID;//Used for the new version of detailMessageVC
@end
