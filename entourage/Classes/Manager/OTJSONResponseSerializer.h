//
//  OTJSONResponseSerializer.h
//  entourage
//
//  Created by Ciprian Habuc on 30/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "AFURLResponseSerialization.h"

static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";
static NSString * const JSONResponseSerializerFullKey = @"JSONResponseSerializerFullKey";

@interface OTJSONResponseSerializer : AFJSONResponseSerializer

@end
