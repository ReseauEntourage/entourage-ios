//
//  OTMenuTableViewCell.h
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const OTMenuTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const OTMenuLogoutTableViewCellIdentifier;
FOUNDATION_EXPORT NSString *const OTMenuMakeDonationTableViewCellIdentifier;

@interface OTMenuTableViewCell : UITableViewCell

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, weak) IBOutlet UIImageView *itemIcon;
@property (nonatomic, weak) IBOutlet UILabel *itemLabel;

@end
