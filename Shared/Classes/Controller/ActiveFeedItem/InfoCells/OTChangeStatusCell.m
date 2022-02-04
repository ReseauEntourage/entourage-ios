//
//  OTChangeStatusCell.m
//  entourage
//
//  Created by Smart Care on 25/09/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTChangeStatusCell.h"
#import "OTStatusBehavior.h"
#import "entourage-Swift.h"

@implementation OTChangeStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWith:(OTFeedItem *)item {
    self.lblStatus.text = [OTStatusBehavior statusTitleForItem:item];
    self.lblStatus.textColor = [ApplicationTheme shared].backgroundThemeColor;
}

@end
