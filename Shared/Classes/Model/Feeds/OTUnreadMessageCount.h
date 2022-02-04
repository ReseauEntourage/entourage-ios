//
//  OTUnreadMessageCount.h
//  entourage
//
//  Created by veronica.gliga on 15/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTUnreadMessageCount : NSObject

@property (nonatomic, strong) NSNumber *feedId;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSNumber *unreadMessagesCount;

@end
