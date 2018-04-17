//
//  OTAboutTableViewCell.h
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString* const OTAboutTableViewCellIdentifier;

@interface OTAboutTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *extraLabel;

@end
