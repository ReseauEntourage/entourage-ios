//
//  OTStatusButtonCell.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStatusButtonCell.h"

@implementation OTStatusButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.statusBehavior initialize];
    self.statusBehavior.lblStatus = self.lblStatus;
    self.statusBehavior.btnStatus = self.btnStatus;
}

- (void)configureWith:(OTFeedItem *)item {
    [self.statusBehavior updateWith:item];
}

@end
