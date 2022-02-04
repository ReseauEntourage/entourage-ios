//
//  OTEventCreatedCellTableViewCell.m
//  entourage
//
//  Created by Smart Care on 03/08/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//
#define BUTTON_MARGIN 144

#import "OTEventCreatedCell.h"
#import "OTTableDataSourceBehavior.h"
#import "UIColor+Expanded.h"
#import "entourage-Swift.h"

@implementation OTEventCreatedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];

    [self.viewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewButton setBackgroundColor:[ApplicationTheme shared].backgroundThemeColor];
    self.iconButton.layer.borderColor = [UIColor colorWithHexString:@"9E9E9E"].CGColor;
    self.iconButton.layer.borderWidth = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemMessage *messageItem = (OTFeedItemMessage*)timelinePoint;
    self.messageLabel.attributedText = [OTAppAppearance formattedEventCreatedMessageInfo:messageItem];
}

- (IBAction)viewEventAction:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItemMessage *messageItem = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    
    NSDictionary *userInfo =  @{@kNotificationFeedItemKey: messageItem};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowEventDetails object:nil userInfo:userInfo];
}

@end
