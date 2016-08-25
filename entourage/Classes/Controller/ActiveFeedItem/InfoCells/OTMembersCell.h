//
//  OTMembersCell.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemJoiner.h"

@interface OTMembersCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;

- (void)configureWith:(OTFeedItemJoiner *)member;

@end
