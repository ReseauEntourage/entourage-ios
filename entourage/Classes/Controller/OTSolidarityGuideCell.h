//
//  OTSolidarityGuideCell.h
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTPoi.h"

extern NSString* const OTSolidarityGuideTableViewCellIdentifier;

@interface OTSolidarityGuideCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *typeLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UILabel *distanceLabel;

- (void)configureWith:(OTPoi *)poi;

@end
