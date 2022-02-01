//
//  OTEntourageChangedHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/31/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTEntourageChangedHandler.h"

@implementation OTEntourageChangedHandler

- (void)updateWith:(OTFeedItem *)feedItem {
    OTEntourage *entourage = (OTEntourage *)feedItem;
    self.entourage.categoryObject = entourage.categoryObject;
    self.entourage.category = entourage.category;
    self.entourage.title = entourage.title;
    self.entourage.desc = entourage.desc;
    self.entourage.location = entourage.location;
    self.entourage.entourage_type = entourage.entourage_type;
}

@end
