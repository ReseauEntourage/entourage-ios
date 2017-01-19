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
#import "UIImageView+entourage.h"

@implementation OTMessageReceivedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    if([timelinePoint isKindOfClass:[OTFeedItemJoiner class]])
        [self configureWithJoin:(OTFeedItemJoiner *)timelinePoint];
    else
        [self configureWithMessage:(OTFeedItemMessage *)timelinePoint];
}

- (IBAction)showUserDetails:(id)sender {
    [Flurry logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemMessage *message = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:message.uID];
}

#pragma mark - private methods

- (void)configureWithMessage:(OTFeedItemMessage *)message {
    self.lblUserName.text = message.userName;
    
#warning TODO remove this (just for testing)
    [self.imgAssociation setupFromUrl:message.userAvatarURL withPlaceholder:@"user"];
    
    [self.btnAvatar setupAsProfilePictureFromUrl:message.userAvatarURL];
    self.txtMessage.text = message.text;
}

- (void)configureWithJoin:(OTFeedItemJoiner *)joiner {
    self.lblUserName.text = joiner.displayName;
    
#warning TODO remove this (just for testing)
    [self.imgAssociation setupFromUrl:joiner.avatarUrl withPlaceholder:@"user"];
    
    [self.btnAvatar setupAsProfilePictureFromUrl:joiner.avatarUrl];
    self.txtMessage.text = [NSString stringWithFormat:@"\"%@\"", joiner.message];
}

@end
