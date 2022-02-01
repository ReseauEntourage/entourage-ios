//
//  OTMembersCell.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemJoiner.h"
#import "OTUserProfileBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTBaseInfoCell.h"
#import "TTTAttributedLabel.h"

@interface OTEventInfoCell : OTBaseInfoCell <TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblAuthorPrefix;
@property (nonatomic, weak) IBOutlet UILabel *lblAuthorInfo;
@property (nonatomic, weak) IBOutlet UILabel *lblInfo;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *lblLocation;
@property (nonatomic, weak) IBOutlet UIImageView *imgIcon;

- (void)configureWith:(OTFeedItem *)item;

@end
