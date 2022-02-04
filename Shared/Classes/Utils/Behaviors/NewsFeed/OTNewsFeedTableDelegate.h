//
//  OTNewsFeedTableDelegate.h
//  entourage
//
//  Created by veronica.gliga on 18/05/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol OTNewsFeedTableDelegate <NSObject>

- (void)beginUpdatingFeeds;
- (void)finishUpdatingFeeds: (BOOL)withFeeds;
- (void)errorUpdatingFeeds;

@end
