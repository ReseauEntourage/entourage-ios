//
//  OTJoinRequestedCell.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTMessageDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"

@interface OTJoinRequestedCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet UIButton *btnLast;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblJoinType;
@property (nonatomic, weak) IBOutlet UILabel *lblMessage;
@property (nonatomic, weak) IBOutlet OTMessageDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfile;

@end
