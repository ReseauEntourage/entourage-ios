//
//  OTUnreadMessagesService.h
//  entourage
//
//  Created by veronica.gliga on 15/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTUnreadMessagesService : NSObject

+ (OTUnreadMessagesService *)sharedInstance;

- (void)addUnreadMessage:(NSNumber *)feedId;
- (void)removeUnreadMessages:(NSNumber *)feedId;
- (NSNumber *)countUnreadMessages:(NSNumber *)feedId;
- (NSNumber *)totalCount;

@end
