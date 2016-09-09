//
//  OTMyFeedMessage.m
//  entourage
//
//  Created by sergiu buceac on 9/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyFeedMessage.h"
#import "NSDictionary+Parsing.h"

#define kWSText @"text"

@implementation OTMyFeedMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.text = [dictionary valueForKey:kWSText];
    }
    return self;
}

@end
