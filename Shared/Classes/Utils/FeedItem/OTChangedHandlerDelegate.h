//
//  OTChangedHandlerDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/31/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

@protocol OTChangedHandlerDelegate <NSObject>

- (void)updateWith:(OTFeedItem *)feedItem;

@end
