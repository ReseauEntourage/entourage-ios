//
//  OTMessageTableDelegateBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableDelegateBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemMessage.h"

#define MESSAGE_FONT_REGULAR_DESCRIPTION @"SFUIText-Regular"
#define MESSAGE_FONT_SIZE 17
// Sergiu: sorry for these next terrible hardcoded constants (autolayout ios sucks for cells)
#define MESSAGE_CELL_SENT_HORIZONTAL_MARGINS 111.0f
#define MESSAGE_CELL_SENT_VERTICAL_MARGINS 33.0f
#define MESSAGE_CELL_RECEIVED_HORIZONTAL_MARGINS 158.0f
#define MESSAGE_CELL_RECEIVED_VERTICAL_MARGINS 54.0f

@interface OTMessageTableDelegateBehavior ()

@property (nonatomic, strong) UIFont *messageFont;

@end

@implementation OTMessageTableDelegateBehavior

- (void)initialize {
    self.tableDataSource.dataSource.tableView.delegate = self;
    self.messageFont = [UIFont fontWithName:MESSAGE_FONT_REGULAR_DESCRIPTION size:MESSAGE_FONT_SIZE];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTFeedItemTimelinePoint *item = (OTFeedItemTimelinePoint *)[self.tableDataSource getItemAtIndexPath:indexPath];
    MessageCellType cellType = [self.tableDataSource getCellType:item];
    switch (cellType) {
        case MessageCellTypeSent:
            return [self heightForSentMessageCell:(OTFeedItemMessage *)item];
        case MessageCellTypeReceived:
            return [self heightForReceivedMessageCell:(OTFeedItemMessage *)item];
        case MessageCellTypeJoinAccepted:
        case MessageCellTypeJoinRequested:
            return 290;
        case MessageCellTypeStatus:
            return 99;
        default:
            return 60;
    }
}

#pragma mark - private methods

- (CGFloat)heightForSentMessageCell:(OTFeedItemMessage *)message {
    CGFloat maxWidth = self.tableDataSource.dataSource.tableView.contentSize.width - MESSAGE_CELL_SENT_HORIZONTAL_MARGINS;
    CGFloat height = [self heightFor:message withMaxWidth:maxWidth];
    return height + MESSAGE_CELL_SENT_VERTICAL_MARGINS;
}

- (CGFloat)heightForReceivedMessageCell:(OTFeedItemMessage *)message {
    CGFloat maxWidth = self.tableDataSource.dataSource.tableView.contentSize.width - MESSAGE_CELL_RECEIVED_HORIZONTAL_MARGINS;
    CGFloat height = [self heightFor:message withMaxWidth:maxWidth];
    return height + MESSAGE_CELL_RECEIVED_VERTICAL_MARGINS;
}

- (CGFloat)heightFor:(OTFeedItemMessage *)message withMaxWidth:(CGFloat)maxWidth {
    CGRect computed = [message.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.messageFont} context:nil];
    return computed.size.height;
}

@end
