//
//  OTFeedItemsFilterCell.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemsFilterCellBase.h"

@interface OTFeedItemsFilterCell : OTFeedItemsFilterCellBase

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UISwitch *swtActive;

@end
