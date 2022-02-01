//
//  OTAboutTableViewCell.h
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString* const OTAboutTableViewCellIdentifier;
FOUNDATION_EXPORT NSString* const OTAboutTableViewCellWithIconIdentifier;

@interface OTAboutTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *extraLabel;
@property(nonatomic, weak) IBOutlet UIImageView *iconView;

@end
