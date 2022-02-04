//
//  OTAssociationTableViewCell.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAssociation.h"

@interface OTAssociationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIButton *btnLogo;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;

- (void)configureWith:(OTAssociation *)association;

@end
