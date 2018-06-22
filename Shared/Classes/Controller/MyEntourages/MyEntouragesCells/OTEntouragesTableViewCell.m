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
    
    NSString *lastMessage = [self getAuthorTextFor:item.lastMessage];
    
    if ([self.lblLastMessage.text length] > 0) {
        self.lblLastMessage.text = lastMessage;
    } else {
        self.summaryProvider.lblDescription = self.lblLastMessage;
    }
    
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    self.summaryProvider.imgCategory = self.imgCategory;
    self.summaryProvider.showRoundedBorder = YES;
    self.summaryProvider.showTimeAsUpdatedDate = YES;
    self.summaryProvider.imgCategorySize = CGSizeMake(25, 25);
    
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
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItem *feedItem = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:feedItem.author.uID];
}

#pragma mark - private methods

- (NSString *)getAuthorTextFor:(OTMyFeedMessage *)lastMessage {
    NSMutableString *result = [NSMutableString new];
    if(lastMessage.firstName.length > 0)
        [result appendString:lastMessage.firstName];
    if(lastMessage.lastName.length > 0)
        [result appendFormat:@" %@", [lastMessage.lastName substringToIndex:1]];
    if(result.length > 0)
        [result appendString:@": "];
    if(lastMessage.text)
        [result appendString:lastMessage.text];
    return result;
}

@end
