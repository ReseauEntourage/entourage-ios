//
//  OTPrivateCircleCell.m
//  entourage
//
//  Created by Smart Care on 23/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTUserGroupCell.h"
#import "UIButton+entourage.h"
#import "UIImageView+entourage.h"

@implementation OTUserGroupCell

- (void)configureWithItem:(OTUserMembershipListItem*)membershipItem {
    self.lblDisplayName.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    self.lblDisplayName.text = membershipItem.title;
    
    self.lblCount.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    self.lblCount.text = [NSString stringWithFormat:@"%ld", membershipItem.noOfPeople.longValue];
    
    self.btnProfile.layer.cornerRadius = 20;
    self.btnProfile.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.btnProfile.layer.borderWidth = 2;
    
    UIImage *icon = [UIImage imageNamed:[membershipItem membershipIconName]];
    [self.btnProfile setImage:icon forState:UIControlStateNormal];
}

@end
