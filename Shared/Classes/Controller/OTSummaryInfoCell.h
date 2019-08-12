//
//  OTSummaryInfoCell.h
//  entourage
//
//  Created by sergiu buceac on 10/27/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTBaseInfoCell.h"
#import "OTSummaryProviderBehavior.h"

@interface OTSummaryInfoCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet UILabel *lblUserCount;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (nonatomic, weak) IBOutlet UIImageView *imgCategory;

@end
