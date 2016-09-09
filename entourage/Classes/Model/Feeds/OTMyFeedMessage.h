//
//  OTMyFeedMessage.h
//  entourage
//
//  Created by sergiu buceac on 9/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMyFeedMessage : NSObject

@property (nonatomic, strong) NSString *text;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
