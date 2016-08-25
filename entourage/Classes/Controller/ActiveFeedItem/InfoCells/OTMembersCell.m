//
//  OTMembersCell.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersCell.h"
#import "UIButton+entourage.h"

@implementation OTMembersCell

- (void)configureWith:(OTFeedItemJoiner *)member {
    self.lblDisplayName.text = member.displayName;
    [self.btnProfile setupAsProfilePictureFromUrl:member.avatarUrl];
}

@end
