//
//  OTEntourageEditItemCell.h
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTEntourageEditItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblCategory;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;

- (void)configureWith:(NSString *)title andText:(NSString *)description;

@end
