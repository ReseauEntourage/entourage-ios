//
//  OTEventCreatedCell.h
//  entourage
//
//  Created by Smart Care on 03/08/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTMessageDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTFeedItemMessage.h"

@interface OTEventCreatedCell : OTChatCellBase
@property (nonatomic, weak) IBOutlet OTMessageDataSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet UIButton *viewButton;
@property (nonatomic, weak) IBOutlet UIButton *iconButton;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

- (IBAction)viewEventAction:(id)sender;
@end
