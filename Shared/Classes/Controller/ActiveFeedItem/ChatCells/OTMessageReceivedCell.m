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
#import "NSDate+OTFormatter.h"
#import "UIColor+entourage.h"

@implementation OTMessageReceivedCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    self.isPOI = NO;
    self.widthPicto =  self.ui_constraint_width_iv_link.constant;
    
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    if([timelinePoint isKindOfClass:[OTFeedItemJoiner class]])
        [self configureWithJoin:(OTFeedItemJoiner *)timelinePoint];
    else {
        [self configureWithMessage:(OTFeedItemMessage *)timelinePoint];
        if ([((OTFeedItemMessage*)timelinePoint).itemType isEqualToString:@"poi"]) {
            self.isPOI = YES;
            NSString * poiIdString = ((OTFeedItemMessage*)timelinePoint).itemUuid;
            
            NSNumber *poiId = [NSNumber numberWithInt:[poiIdString intValue]];
            
            self.poiId = poiId;
        }
        else if([((OTFeedItemMessage*)timelinePoint).itemType isEqualToString:@"entourage"]) {
            self.ui_constraint_width_iv_link.constant = self.widthPicto;
            [self.txtMessage setTextColor:[UIColor appOrangeColor]];
            [self.time setTextColor:[UIColor appOrangeColor]];
            self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appOrangeColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        }
        else {
            self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appOrangeColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            [self.txtMessage setTextColor:[UIColor blackColor]];
            [self.time setTextColor:[UIColor colorWithRed:118 / 255 green:118 / 255 blue:118 / 255 alpha:1.0]];
            self.ui_constraint_width_iv_link.constant = 0;
        }
    }
    //Used for the new version of detailMessageVC
    if ([timelinePoint isKindOfClass:[OTFeedItemMessage class]]) {
        self.userMessageUID = ((OTFeedItemMessage*) timelinePoint).uID;
    }
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemMessage *message = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:message.uID];
    
    //Used for the new version of detailMessageVC
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserProfile" object:nil userInfo:@{@"userUID":self.userMessageUID}];
}

#pragma mark - private methods

- (void)configureWithMessage:(OTFeedItemMessage *)message {
    self.lblUserName.text = message.userName;
    self.imgAssociation.hidden = message.partner == nil;
    [self.imgAssociation setupFromUrl:message.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    [self.btnAvatar setupAsProfilePictureFromUrl:message.userAvatarURL];
    self.txtMessage.text = message.text;
    self.time.text = [message.date toTimeString];
}

- (void)configureWithJoin:(OTFeedItemJoiner *)joiner {
    self.lblUserName.text = joiner.displayName;
    self.imgAssociation.hidden = joiner.partner == nil;
    [self.imgAssociation setupFromUrl:joiner.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    [self.btnAvatar setupAsProfilePictureFromUrl:joiner.avatarUrl];
    self.txtMessage.text = joiner.message;
    self.time.text = [joiner.date toTimeString];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if (self.isPOI) {
        [[OTDeepLinkService new] showDetailPoiViewControllerWithId:self.poiId];
        
        return false;
    }
    
    return [super textView:textView shouldInteractWithURL:URL inRange:characterRange];
}

- (IBAction)action_show_link:(id)sender {
    if (self.isPOI) {
        [[OTDeepLinkService new] showDetailPoiViewControllerWithId:self.poiId];
    }
}

@end
