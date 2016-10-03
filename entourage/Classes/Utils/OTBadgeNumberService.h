//
//  OTBadgeNumberService.h
//  entourage
//
//  Created by sergiu buceac on 10/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTBadgeNumberService : NSObject

+ (OTBadgeNumberService*) sharedInstance;

@property (nonatomic, readonly, strong) NSNumber *badgeCount;
- (void)updateItem:(NSNumber *)itemId;
- (void)readItem:(NSNumber *)itemId;
- (void)clearData;

@end
