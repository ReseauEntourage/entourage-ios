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

- (void)setTotalUnreadCount:(NSNumber *)count;
- (void)setGroupUnreadMessagesCount:(NSNumber *)feedId stringId:(NSString*)stringId count:(NSNumber *)count;
- (void)incrementGroupUnreadMessagesCount:(NSNumber *)feedId stringId:(NSString*)stringId;
- (void)setGroupAsRead:(NSNumber *)feedId stringId:(NSString*)stringId refreshFeed:(BOOL)refreshFeed;
- (NSNumber *)countUnreadMessages:(NSNumber *)feedId stringId:(NSString*)stringId;
- (NSNumber *)totalCount;

@end
