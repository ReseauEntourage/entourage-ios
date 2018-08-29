//
//  OTPrivateCircleCell.h
//  entourage
//
//  Created by Smart Care on 23/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTUserMembership.h"

@interface OTUserGroupCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;

- (void)configureWithItem:(OTUserMembershipListItem*)membershipItem;
@end
