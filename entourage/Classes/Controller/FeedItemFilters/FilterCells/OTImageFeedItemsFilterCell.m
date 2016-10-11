//
//  OTImageFeedItemsFilterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTImageFeedItemsFilterCell.h"

@implementation OTImageFeedItemsFilterCell

- (void)configureWith:(OTFeedItemFilter *)filter {
    [super configureWith:filter];
    
    self.image.image = [UIImage imageNamed:filter.image];
}

@end
