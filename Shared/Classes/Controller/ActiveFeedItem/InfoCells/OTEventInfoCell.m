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

@implementation OTEventInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureWith:(OTFeedItem *)item {
    if (item.startsAt) {
        NSAttributedString *description = [[[OTFeedItemFactory createFor:item] getUI] eventInfoFormattedDescription];
        self.lblInfo.attributedText = description;
    }
}


@end
