//
//  OTTourJoiner.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTTourJoiner : NSObject

@property (strong, nonatomic) NSNumber *uID;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSDate *requestedAtDate;
@property (strong, nonatomic) NSString *status;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
