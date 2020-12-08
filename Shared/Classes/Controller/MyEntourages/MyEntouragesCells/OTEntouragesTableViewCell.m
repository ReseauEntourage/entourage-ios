//
//  OTEntouragesTableViewCell.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesTableViewCell.h"
#import "UIColor+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@implementation OTEntouragesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureWith:(OTFeedItem *)item {
    UIFont *readFontLarge = [UIFont fontWithName:@"SFUIText-Regular" size:16];
    UIFont *unReadFontLarge = [UIFont fontWithName:@"SFUIText-Bold" size:16];
    UIFont *readFontSmall = [UIFont fontWithName:@"SFUIText-Regular" size:14];
    UIFont *unReadFontSmall = [UIFont fontWithName:@"SFUIText-Bold" size:14];
    
    UIColor *readColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    UIFont *lightFont = [UIFont fontWithName:@"SFUIText-Light" size:14];
    
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    self.summaryProvider.imgCategory = self.imgCategory;
    self.summaryProvider.showRoundedBorder = YES;
    self.summaryProvider.showTimeAsUpdatedDate = YES;
    self.summaryProvider.imgCategorySize = CGSizeMake(25, 25);
    
    [self setupSubtitleLabelWithItem:item];
    self.summaryProvider.isFromMyEntourages = YES;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
    
    if (item.unreadMessageCount.intValue > 0) {
        self.lblTitle.font = unReadFontLarge;
        self.lblTitle.textColor = [UIColor blackColor];
        
        self.lblLastMessage.font = unReadFontSmall;
        self.lblLastMessage.textColor = [UIColor blackColor];
        
        self.lblTimeDistance.font = unReadFontSmall;
        self.lblTimeDistance.textColor = [UIColor blackColor];
    }
    else {
        self.lblTitle.font = readFontLarge;
        self.lblTitle.textColor = readColor;
        
        self.lblLastMessage.font = readFontSmall;
        self.lblLastMessage.textColor = [UIColor appGreyishColor];
        
        self.lblTimeDistance.font = lightFont;
        self.lblTimeDistance.textColor = readColor;
    }

    [self setupSubtitleLabelWithItem:item];
}

- (void)setupSubtitleLabelWithItem:(OTFeedItem*)item {
    NSString *lastMessage = [self getAuthorTextFor:item.lastMessage];
    if ([lastMessage length] > 0) {
        self.summaryProvider.lblDescription = self.lblLastMessage;
        self.lblLastMessage.text = lastMessage;
    } else {
        self.summaryProvider.lblDescription = self.lblLastMessage;
    }
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItem *feedItem = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:feedItem.author.uID];
}

#pragma mark - private methods

- (NSString *)getAuthorTextFor:(OTMyFeedMessage *)lastMessage {
    OTUser * currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    BOOL isMe = [currentUser.sid isEqual:lastMessage.authorId];
    
    NSMutableString *result = [NSMutableString new];
    if (isMe) {
        [result appendString:@"Vous"];
    }
    else {
        if (lastMessage.displayName.length > 0) {
            [result appendString:lastMessage.displayName];
        }
    }
    
    if(result.length > 0) {
        [result appendString:@" : "];
        if (lastMessage.text) {
            [result appendString:lastMessage.text];
        }
    }
    
    return result;
}

@end
