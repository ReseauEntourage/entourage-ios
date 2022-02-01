//
//  OTFeedItemsFilterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTFeedItemsFilterCell.h"
#import "OTFeedItemFilter.h"
#import "OTDataSourceBehavior.h"
#import "OTConsts.h"

@implementation OTFeedItemsFilterCell

- (void)configureWith:(OTFeedItemFilter *)filter {
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:filter.title];
    if (filter.showBoldText) {
        title = [self attributedTitle:filter.title boldChars:filter.title.length];
    }
    self.lblTitle.attributedText = title;
    [self.swtActive setOn:filter.active animated:NO];
    self.swtActive.tag = filter.key;
}

- (NSMutableAttributedString *) attributedTitle: (NSString *)title
                                      boldChars: (NSUInteger)range {
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange selectedRange = NSMakeRange(0, range);
    [attributedTitle beginEditing];
    
    [attributedTitle addAttribute:NSFontAttributeName
              value:[UIFont fontWithName:@"SFUIText-Bold" size:15.0]
              range:selectedRange];
    
    [attributedTitle endEditing];
    return attributedTitle;
}

- (IBAction)changeActive:(id)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    
    OTFeedItemFilter *item = (OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    UISwitch *swtControl = (UISwitch *)sender;
    item.active = swtControl.isOn;
    
    //To switch from all / partnersOnly Bold + switch
    if (item.key == FeedItemFilterKeyAlls) {
        NSIndexPath * newIndexP = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
        ((OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:newIndexP]).active = !swtControl.isOn;
        ((OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:newIndexP]).showBoldText = !swtControl.isOn;
        item.showBoldText = swtControl.isOn;
    }
    else if(item.key == FeedItemFilterKeyPartners) {
        NSIndexPath * newIndexP = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        ((OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:newIndexP]).active = !swtControl.isOn;
        ((OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:newIndexP]).showBoldText = !swtControl.isOn;
        item.showBoldText = swtControl.isOn;
    }
    
    for (OTFeedItemFilter *child in item.subItems) {
        child.active = swtControl.isOn;
    }
    [self.tableDataSource.dataSource.tableView reloadData];
    NSString *message = @"";
    
    switch (item.key) {
        case FeedItemFilterKeyMedical:
            message = @"ShowOnlyMedicalToursClick";
            break;
        case FeedItemFilterKeySocial:
            message = @"ShowOnlySocialToursClick";
            break;
        case FeedItemFilterKeyDistributive:
            message = @"ShowOnlyDistributionToursClick";
            break;
        case FeedItemFilterKeyDemand:
            [OTLogger logEvent:@"AskMessagesFilter"];
            message = @"ShowOnlyAsksClick";
            break;
            
        case FeedItemFilterKeyContribution:
            [OTLogger logEvent:@"OfferMessagesFilter"];
            message = @"ShowOnlyOffersClick";
            break;
        case FeedItemFilterKeyTour:
            message = @"ShowOnlyToursFilterClick";
            [OTLogger logEvent:@"TourMessagesFilter"];
            break;
        case FeedItemFilterKeyUnread:
            message = @"OrganizerFilter";
            break;
        case FeedItemFilterKeyIncludingClosed:
            message = @"PastFilter";
            break;
        case FeedItemFilterKeyEvents:
            message = @"EventsFilter";
            break;
        case FeedItemFilterKeyEventsPast:
            message = @"PastEventsFilter";
            break;
        case FeedItemFilterKeyAlls:
            message = @"ShowAllsFilter";
            break;
        case FeedItemFilterKeyPartners:
            message = @"ShowPartnersOnlyFilter";
            break;
        default:
            break;
    }
    [OTLogger logEvent:message];
}

@end
