//
//  OTAboutTableViewCell.m
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAboutTableViewCell.h"

NSString* const OTAboutTableViewCellIdentifier = @"OTAboutTableViewCellIdentifier";

@implementation OTAboutTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.titleLabel.highlighted = highlighted;
}

@end
