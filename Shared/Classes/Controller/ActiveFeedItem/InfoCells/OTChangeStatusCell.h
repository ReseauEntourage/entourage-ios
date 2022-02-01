//
//  OTChangeStatusCell.h
//  entourage
//
//  Created by Smart Care on 25/09/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTBaseInfoCell.h"
#import "OTStatusChangedBehavior.h"

@interface OTChangeStatusCell : OTBaseInfoCell
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;

- (void)configureWith:(OTFeedItem *)item;

@end
