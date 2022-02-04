//
//  OTUserPermissions.h
//  entourage
//
//  Created by Jerome on 14/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface OTUserPermissions : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic) BOOL isEventCreationActive;
@end
