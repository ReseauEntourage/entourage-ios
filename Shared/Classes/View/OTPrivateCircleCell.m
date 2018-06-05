//
//  OTPrivateCircleCell.m
//  entourage
//
//  Created by Smart Care on 23/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTPrivateCircleCell.h"
#import "UIButton+entourage.h"
#import "UIImageView+entourage.h"

@implementation OTPrivateCircleCell

- (void)configureWithItem:(OTUserMembershipListItem*)membershipItem {
    self.lblDisplayName.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    self.lblDisplayName.text = membershipItem.title;
    
    self.lblCount.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    self.lblCount.text = [NSString stringWithFormat:@"%ld", membershipItem.noOfPeople.longValue];
}

@end
