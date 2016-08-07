//
//  OTMessageReceivedCell.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTPaddedLabel.h"

@interface OTMessageReceivedCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet OTPaddedLabel *lblMessage;

@end
