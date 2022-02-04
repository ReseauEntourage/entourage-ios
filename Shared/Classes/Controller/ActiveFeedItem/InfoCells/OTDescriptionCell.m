//
//  OTDescriptionCell.m
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTDescriptionCell.h"
#import "OTFeedItem.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"

@implementation OTDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtDescription.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appGreyishBrownColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
}

- (void)configureWith:(OTFeedItem *)item {    
    NSString *description = [[[OTFeedItemFactory createFor:item] getUI] feedItemDescription];
    self.txtDescription.text = description;
}

@end
