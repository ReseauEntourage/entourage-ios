//
//  OTMessageReceivedCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageReceivedCell.h"
#import "OTFeedItemMessage.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"

@implementation OTMessageReceivedCell

- (void)awakeFromNib {
    self.lblMessage.edgeInsets = UIEdgeInsetsMake(8, 17, 8, 17);
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemMessage *msgData = (OTFeedItemMessage *)timelinePoint;
    self.lblUserName.text = msgData.userName;
    [self.btnAvatar setupAsProfilePictureFromUrl:msgData.userAvatarURL];
    self.lblMessage.text = msgData.text;
}

- (IBAction)showUserDetails:(id)sender {
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemMessage *message = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:message.uID];
}

@end
