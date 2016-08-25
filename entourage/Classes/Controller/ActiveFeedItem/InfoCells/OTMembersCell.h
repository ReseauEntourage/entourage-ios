//
//  OTMembersCell.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemJoiner.h"
#import "OTUserProfileBehavior.h"
#import "OTDataSourceBehavior.h"

@interface OTMembersCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfile;
@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;

- (void)configureWith:(OTFeedItemJoiner *)member;

@end
