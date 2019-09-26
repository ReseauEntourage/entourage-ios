//
//  OTTimestampsCell.m
//  entourage
//
//  Created by Grégoire Clermont on 12/08/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTTimestampsCell.h"
#import "OTFeedItemFactory.h"

@implementation OTTimestampsCell

- (void)configureWith:(OTFeedItem *)item {    
    self.timestampsLabel.text = [[[OTFeedItemFactory createFor:item] getUI] formattedTimestamps];
}

@end
