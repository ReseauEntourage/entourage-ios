//
//  OTImageFeedItemsFilterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTImageFeedItemsFilterCell.h"

@implementation OTImageFeedItemsFilterCell

- (void)configureWith:(OTFeedItemFilter *)filter {
    [super configureWith:filter];
    self.image.image = [UIImage imageNamed:filter.image];
    self.image.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
