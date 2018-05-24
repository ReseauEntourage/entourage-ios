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

- (void)configureWithTitle:(NSString*)title url:(NSString*)url {
    self.lblDisplayName.font = [UIFont fontWithName:@"SFUIText-Bold" size:15];
    self.lblDisplayName.text = title;
    [self.btnProfile setupAsProfilePictureFromUrl:url];
    
}
@end
