//
//  OTConversation.h
//  entourage
//
//  Created by Smart Care on 14/06/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTConversation : NSObject
@property (strong, nonatomic) NSString *uuid;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
