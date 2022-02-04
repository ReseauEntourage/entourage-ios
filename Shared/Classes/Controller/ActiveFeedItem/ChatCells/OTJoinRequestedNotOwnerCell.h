//
//  OTJoinRequestedNotOwnerCell.h
//  entourage
//
//  Created by sergiu buceac on 11/1/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTMessageDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"

@interface OTJoinRequestedNotOwnerCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet UIButton *btnLast;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblJoinType;
@property (nonatomic, weak) IBOutlet UILabel *lblMessage;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (nonatomic, weak) IBOutlet OTMessageDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfile;

@property (nonatomic, weak) IBOutlet UILabel *lblAppName;
@property (nonatomic, weak) IBOutlet UIImageView *imgAppLogo;
@property (nonatomic, weak) IBOutlet UIView *bgView;

@end
