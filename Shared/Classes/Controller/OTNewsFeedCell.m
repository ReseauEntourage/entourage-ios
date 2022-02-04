//
//  OTNewsFeedCell.m
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedCell.h"
#import "OTSummaryProviderBehavior.h"
#import "OTFeedItemFactory.h"
#import "UIButton+entourage.h"
#import "entourage-Swift.h"

NSString* const OTNewsFeedTableViewCellIdentifier = @"OTNewsFeedTableViewCellIdentifier";

@interface OTNewsFeedCell ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTNewsFeedCell

- (void)configureWith:(OTFeedItem *) item {
    self.feedItem = item;
    OTSummaryProviderBehavior *summaryBehavior = [OTSummaryProviderBehavior new];
    summaryBehavior.lblTimeDistance = self.timeLocationLabel;
    summaryBehavior.imgAssociation = self.imgAssociation;
    summaryBehavior.imgCategory = self.imgCategory;
    [summaryBehavior configureWith:item];
    
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
   // self.typeByNameLabel.attributedText = [uiDelegate descriptionWithSize:DEFAULT_DESCRIPTION_SIZE hasToShowDate:YES];
    self.organizationLabel.text = [uiDelegate summary];
    if ([UIDevice currentDevice].deviceSize == DeviceSizeSmall) {
        self.organizationLabel.numberOfLines = 3;
    }
    
    if ([OTAppConfiguration shouldShowCreatorImagesForNewsFeedItems]) {
        [self.userProfileImageButton setupAsProfilePictureFromUrl:item.author.avatarUrl];
    } else {
        self.userProfileImageButton.hidden = YES;
        self.imgAssociation.hidden = YES;
    }
    
    self.noPeopleLabel.text = [NSString stringWithFormat:@"%d", item.noPeople.intValue];
    [self.statusButton setupAsStatusButtonForFeedItem:item];
    
    [self.statusTextButton setupAsStatusTextButtonForFeedItem:item];
    self.unreadCountText.hidden = item.unreadMessageCount.intValue == 0;
    self.unreadCountText.text = item.unreadMessageCount.stringValue;
    
    if ([item isKindOfClass:[OTEntourage class]]) {
        OTCategory* cat = [self getCat:item.type andCat:((OTEntourage*)item).category];
        self.ui_label_type.text = cat.title_list;
        if (((OTEntourage*)item).isOuting) {
            self.ui_label_type.text = [self getEventDateInfos:(OTEntourage*)item];
        }
    }
    
   
    self.typeByNameLabel.text = self.feedItem.author.displayName;
}

- (void)configureLightWith:(OTFeedItem *) item {
    self.feedItem = item;
    OTSummaryProviderBehavior *summaryBehavior = [OTSummaryProviderBehavior new];
    summaryBehavior.lblTimeDistance = self.timeLocationLabel;
    summaryBehavior.imgAssociation = self.imgAssociation;
    summaryBehavior.imgCategory = self.imgCategory;
    [summaryBehavior configureWith:item];
    
    self.ui_label_event.text = @"";
    
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
    
    BOOL isEntourage = [item class] == [OTEntourage class];
    BOOL isAnnouncement = [item class] == [OTAnnouncement class];
    
    if (isAnnouncement) {
        self.typeByNameLabel.attributedText = [uiDelegate descriptionWithSize:DEFAULT_DESCRIPTION_SIZE hasToShowDate:YES];
    }
    else if(isEntourage) {
        self.typeByNameLabel.text = [NSString stringWithFormat:@"Par %@",((OTEntourage*)item).author.displayName ];
        
        if ([item isOuting]) {
            self.ui_label_event.text = [self getEventDateInfos:(OTEntourage*)  item];
        }
    }
    else {
        self.typeByNameLabel.text = @"*****";
    }
    
    self.organizationLabel.text = [uiDelegate summary];
    if ([UIDevice currentDevice].deviceSize == DeviceSizeSmall) {
        self.organizationLabel.numberOfLines = 3;
    }
    
    if ([OTAppConfiguration shouldShowCreatorImagesForNewsFeedItems]) {
        [self.userProfileImageButton setupAsProfilePictureFromUrl:item.author.avatarUrl];
    } else {
        self.userProfileImageButton.hidden = YES;
        self.imgAssociation.hidden = YES;
    }
}

-(NSString*) getEventDateInfos:(OTEntourage*)item {
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    if (item.startsAt) {
        NSString *_message = @"";
        if ([[NSCalendar currentCalendar] isDate:item.startsAt inSameDayAsDate:item.endsAt]) {
           _message = [NSString stringWithFormat:@"%@ %@", eventName, [NSString stringWithFormat:OTLocalizedString(@"le_"),[item.startsAt asStringWithFormat:@"EEEE dd/MM"]]];
        }
        else {
            NSString *_dateStr = [NSString stringWithFormat:OTLocalizedString(@"du_au"), [item.startsAt asStringWithFormat:@"dd/MM"],[item.endsAt asStringWithFormat:@"dd/MM"]];
            _message = [NSString stringWithFormat:@"%@ %@", eventName,_dateStr ];
        }
        
        return _message;
    } else {
        return eventName;
    }
}

-(OTCategory *) getCat:(NSString*) type andCat:(NSString*)category {
    OTCategory* cat = [[OTCategory alloc]init];
    if ([OTCategoryFromJsonService getData]) {
        for (OTCategoryType* item in [OTCategoryFromJsonService getData]) {
            if ([item.type isEqualToString:type]) {
                for (id item2 in item.categories) {
                    if ([item2 isKindOfClass:[OTCategory class]]) {
                        if ([((OTCategory*) item2).category isEqualToString:category]) {
                            cat = (OTCategory*) item2;
                            break;
                        }
                    }
                }
                break;
            }
        }
    }
    return cat;
}

- (IBAction)doShowProfile {
    [OTLogger logEvent:@"UserProfileClick"];
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(showUserProfile:)])
        [self.tableViewDelegate showUserProfile:self.feedItem.author.uID];
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserProfileFromFeed" object:self.feedItem.author.uID];
    }
}

- (IBAction)doJoinRequest {
    NSLog(@"***** do join request");
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(doJoinRequest:)])
        [self.tableViewDelegate doJoinRequest:self.feedItem];
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMenuFromFeed" object:self.feedItem];
    }
}

@end
