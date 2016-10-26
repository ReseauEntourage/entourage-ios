//
//  OTStatusButtonCell.h
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTStatusBehavior.h"
#import "OTBaseInfoCell.h"
#import "OTFeedItem.h"

@interface OTStatusButtonCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet UILabel *lblStatus;
@property (nonatomic, weak) IBOutlet UIButton *btnStatus;

@property (nonatomic, weak) IBOutlet OTStatusBehavior *statusBehavior;

@end
