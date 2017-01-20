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
#warning TODO remove this (just for testing)
    [self.imgAssociation setupFromUrl:item.avatarUrl withPlaceholder:@"user"];
    
    self.lblDisplayName.text = item.displayName;
    [self.btnProfile setupAsProfilePictureFromUrl:item.avatarUrl];
}

@end
