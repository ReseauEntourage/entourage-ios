//
//  OTEntouragesTableViewCell.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@interface OTEntouragesTableViewCell : UITableViewCell

- (void)configureWith:(OTFeedItem *)item;

@end
