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
#import "OTBaseInfoCell.h"

@interface OTMembersCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;

@end
