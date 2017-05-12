//
//  OTNewsFeedCell.h
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemsTableView.h"

extern NSString* const OTNewsFeedTableViewCellIdentifier;

@interface OTNewsFeedCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *organizationLabel;
@property(nonatomic, weak) IBOutlet UILabel *typeByNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLocationLabel;
@property(nonatomic, weak) IBOutlet UIButton *userProfileImageButton;
@property(nonatomic, weak) IBOutlet UILabel *noPeopleLabel;
@property(nonatomic, weak) IBOutlet UIButton *statusButton;
@property(nonatomic, weak) IBOutlet UIButton *statusTextButton;
@property(nonatomic, weak) IBOutlet UITextField *unreadCountText;
@property(nonatomic, weak) IBOutlet UIView *statusLineMarker;
@property(nonatomic, weak) IBOutlet UIImageView *imgAssociation;

@property(nonatomic, weak) IBOutlet id<OTFeedItemsTableViewDelegate> tableViewDelegate;

-(void)configureWith:(OTFeedItem *)item;

@end
