//
//  OTEntourageEditItemCell.h
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTEntourageEditItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;
@property (nonatomic, weak) IBOutlet UISwitch *privacySwitch;

- (void)configureWith:(NSString *)title andText:(NSString *)description;
- (void)configureWithTitle:(NSString *)title
               description:(NSString*)description
                 isPrivate:(BOOL)isPrivate;

@end
