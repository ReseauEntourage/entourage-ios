//
//  OTFeedItemAuthor.h
//  entourage
//
//  Created by Ciprian Habuc on 17/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTFeedItemAuthor : NSObject

@property (strong, nonatomic) NSNumber *uID;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *displayName;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
