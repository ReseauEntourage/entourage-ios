//
//  OTEntouragesTableViewCell.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesTableViewCell.h"
#import "UIColor+entourage.h"

@implementation OTEntouragesTableViewCell

- (void)awakeFromNib {
    self.lblNumberOfUsers.layer.borderColor = [UIColor appGreyishColor].CGColor;
}

- (void)configureWith:(OTFeedItem *)item {
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblDescription = self.lblDescription;
    self.summaryProvider.lblUserCount = self.lblNumberOfUsers;
    self.summaryProvider.btnAvatar = self.btnProfilePicture;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
    self.lblNumberOfUsers.text = [@"+" stringByAppendingString:self.lblNumberOfUsers.text];
    self.lblLastMessage.text = item.lastMessage.text;
}

@end
