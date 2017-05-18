//
//  OTEntourageEditItemImageCell.m
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEntourageEditItemImageCell.h"

@implementation OTEntourageEditItemImageCell

- (void)configureWith:(NSString *)title andText:(NSString *)description andImageName:(NSString *)imageName {
    [super configureWith:title andText:description];
    self.itemImageView.image = [UIImage imageNamed:imageName];
}

@end
