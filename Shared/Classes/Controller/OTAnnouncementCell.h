//
//  OTAnnouncementCell.h
//  entourage
//
//  Created by veronica.gliga on 02/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemsTableView.h"

extern NSString* const OTAnnouncementTableViewCellIdentifier;

@interface OTAnnouncementCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconImage;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *statusTextButton;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *contentImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentImageHeightConstraint;

@property(nonatomic, weak) IBOutlet id<OTFeedItemsTableViewDelegate> tableViewDelegate;

- (void)configureWith:(OTFeedItem *) item completion:(void(^)(void))completion;

@end
