//
//  OTMenuTableViewCell.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuTableViewCell.h"

NSString *const OTMenuTableViewCellIdentifier = @"OTMenuTableViewCellIdentifier";

@implementation OTMenuTableViewCell

/**************************************************************************************************/
#pragma mark - Utils

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.itemLabel.highlighted = highlighted;
}

@end
