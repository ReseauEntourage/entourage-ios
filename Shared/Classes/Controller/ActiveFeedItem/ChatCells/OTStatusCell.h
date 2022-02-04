//
//  OTStatusCell.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTChatCellBase.h"

@interface OTStatusCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UIImageView *imgStatus;
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;
@property (nonatomic, weak) IBOutlet UILabel *lblDuration;
@property (nonatomic, weak) IBOutlet UILabel *lblDistance;

@end
