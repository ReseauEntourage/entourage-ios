//
//  OTDescriptionCell.m
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDescriptionCell.h"
#import "OTFeedItem.h"
#import "UIColor+entourage.h"

@implementation OTDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtDescription.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor appGreyishBrownColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
}

- (void)configureWith:(NSString *)item {
    self.txtDescription.text = item;
}

@end
