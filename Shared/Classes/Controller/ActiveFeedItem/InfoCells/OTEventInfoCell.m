//
//  OTMembersCell.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEventInfoCell.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "UIImageView+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTTapViewBehavior.h"

@implementation OTEventInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureWith:(OTFeedItem *)item {
    self.lblAuthorPrefix.text = @"Organisé par ";
    self.lblAuthorInfo.text = [[[OTFeedItemFactory createFor:item] getUI] userName];
    if (item.startsAt) {
        self.lblInfo.text = [[[OTFeedItemFactory createFor:item] getUI] eventInfoDescription];
    }
}


@end
