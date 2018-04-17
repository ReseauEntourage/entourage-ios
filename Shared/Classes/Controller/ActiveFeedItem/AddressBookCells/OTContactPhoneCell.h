//
//  OTContactPhoneCell.h
//  entourage
//
//  Created by sergiu buceac on 9/19/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAddressBookPhone.h"

@interface OTContactPhoneCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblPhoneNumber;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelectState;
- (void)configureWith:(OTAddressBookPhone *)phone;

@end
