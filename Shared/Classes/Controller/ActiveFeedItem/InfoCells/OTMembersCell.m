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
#import "UIImageView+entourage.h"

@implementation OTMembersCell

- (void)configureWith:(OTFeedItemJoiner *)item {
    self.imgAssociation.hidden = item.partner == nil;
    [self.imgAssociation setupFromUrl:item.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    self.lblDisplayName.text = item.displayName;
    [self.btnProfile setupAsProfilePictureFromUrl:item.avatarUrl];
}

@end
