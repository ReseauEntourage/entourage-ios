//
//  OTManageInvitationViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTManageInvitationViewController.h"
#import "UIColor+entourage.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "OTSummaryProviderBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTInvitationChangedBehavior.h"
#import "OTUnreadMessagesService.h"
#import "entourage-Swift.h"

@interface OTManageInvitationViewController () <UITableViewDelegate,UITableViewDataSource,ActionCellCreatorDelegate>

@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTInvitationChangedBehavior *invitationChangedBehavior;
@property (strong, nonatomic) IBOutlet UIButton *btnIgnore;
@property (weak, nonatomic) IBOutlet UITableView *ui_tableview;
@property (nonatomic) NSInteger numberOfCells;
@end

@implementation OTManageInvitationViewController
@synthesize numberOfCells,feedItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfCells = 0;
    
    self.invitationChangedBehavior.pendingInvitationChangedDelegate = self.pendingInvitationsChangedDelegate;
    
    self.title = @"";
    self.btnIgnore.layer.borderColor = [UIColor appOrangeColor].CGColor;
    self.btnIgnore.layer.borderWidth = 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[OTUnreadMessagesService sharedInstance] setGroupAsRead:self.feedItem.uid stringId:self.feedItem.uuid refreshFeed:NO];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (IBAction)accept {
    [self.invitationChangedBehavior accept:self.invitation];
}

- (IBAction)ignore {
    [self.invitationChangedBehavior ignore:self.invitation];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
}

#pragma mark - uitableview Datasource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedItem.isOuting) {
        if (self.feedItem.isEventOnline) {
            numberOfCells = 5;
        }
        else {
            numberOfCells = 6;
        }
        
        return numberOfCells;
    }
    else {
        numberOfCells = 5;
        return numberOfCells;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (feedItem.isOuting) {
        switch (indexPath.row) {
        case 0:
                return [self getCell:indexPath andIdentifier:@"cellTopEvent"];
        case 1:
                return [self getCell:indexPath andIdentifier:@"cellEventDate"];
        case 2:
                return [self getCell:indexPath andIdentifier:@"cellLocation"];
        case 3:
                return [self getCell:indexPath andIdentifier:@"cellCreator"];
        case 4:
                return [self getCell:indexPath andIdentifier:@"cellDescriptionEvent"];
        case 5:
                return [self getCell:indexPath andIdentifier:@"cellMap"];
        default:
                return [self getCell:indexPath andIdentifier:@""];
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                return [self getCell:indexPath andIdentifier:@"cellTop"];
            case 1:
                return [self getCell:indexPath andIdentifier:@"cellLocation"];
            case 2:
                return [self getCell:indexPath andIdentifier:@"cellCreator"];
            case 3:
                return [self getCell:indexPath andIdentifier:@"cellDescription"];
            case 4:
                return [self getCell:indexPath andIdentifier:@"cellMap"];
            default:
                return [self getCell:indexPath andIdentifier:@""];
        }
    }
}


-(UITableViewCell*) getCell:(NSIndexPath*) indexPath andIdentifier:(NSString*) identifier {
    if ([identifier isEqualToString:@"cellTop"] || [identifier isEqualToString:@"cellTopEvent"]) {
        OTDetailActionEventTopCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem:(OTEntourage*) feedItem];
        return cell;
    }
    
    else if ([identifier isEqualToString:@"cellEventDate"]) {
        OTDetailActionEventDateCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem:(OTEntourage*) feedItem];
        return cell;
    }
    
   else if ([identifier isEqualToString:@"cellLocation"]) {
       OTDetailActionEventLocationCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem:(OTEntourage*) feedItem];
        return cell;
    }
    
   else if ([identifier isEqualToString:@"cellCreator"]) {
       OTDetailActionEventCreatorCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem: feedItem authorUser:nil delegate:self];
        return cell;
    }
    else if ([identifier isEqualToString:@"cellDescription"] || [identifier isEqualToString:@"cellDescriptionEvent"]) {
        OTDetailActionEventDescriptionCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem:(OTEntourage*) feedItem];
        return cell;
    }
    else  {
        //MAP
        OTDetailActionEventMapCell *cell = [self.ui_tableview dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell populateWithFeedItem:feedItem];
        return cell;
    }
}
#pragma mark - ActionCellCreatorDelegate
- (void)actionshowPartner {
    
    int assoId = feedItem.author.partner.aid.intValue;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AssociationDetails" bundle:nil];
    UINavigationController *navVc = (UINavigationController*) sb.instantiateInitialViewController;
    
    OTAssociationDetailViewController *detailVc = (OTAssociationDetailViewController*) navVc.topViewController;
    
    detailVc.associationId = assoId;
    [self.navigationController presentViewController:navVc animated:YES completion:nil];
}

- (void)actionShowUser {
    [OTLogger logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

@end
