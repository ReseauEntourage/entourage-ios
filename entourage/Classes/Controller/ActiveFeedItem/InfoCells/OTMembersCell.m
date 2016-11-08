//
//  OTMembersCell.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersCell.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"

@implementation OTMembersCell

- (void)configureWith:(OTFeedItemJoiner *)item {
    self.lblDisplayName.text = item.displayName;
    [self.btnProfile setupAsProfilePictureFromUrl:item.avatarUrl];
}

@end
