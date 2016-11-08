//
//  OTMapCell.m
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapCell.h"

@implementation OTMapCell

- (void)configureWith:(OTFeedItem *)item {
    self.annotationProvider.map = self.map;
    [self.annotationProvider configureWith:item];
    [self.annotationProvider addStartPoint];
    [self.annotationProvider drawData];
}

@end
