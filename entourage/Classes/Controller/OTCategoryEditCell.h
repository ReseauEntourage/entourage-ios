//
//  OTCategoryEditCell.h
//  entourage
//
//  Created by veronica.gliga on 25/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTCategory.h"
#import "OTTableDataSourceBehavior.h"
#import "OTCategoryType.h"

@interface OTCategoryEditCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImage;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;

- (void)configureWith:(OTCategory *)category;

@end
