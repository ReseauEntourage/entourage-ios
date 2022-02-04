//
//  OTContactInfoCell.h
//  entourage
//
//  Created by sergiu buceac on 9/19/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAddressBookItem.h"

@interface OTContactInfoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblFullName;
- (void)configureWith:(OTAddressBookItem *)item;

@end
