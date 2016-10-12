//
//  OTJSONResponseSerializer.h
//  entourage
//
//  Created by Ciprian Habuc on 30/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "AFURLResponseSerialization.h"

static NSString * const JSONResponseSerializerFullKey = @"JSONResponseSerializerFullKey";
static NSString * const JSONResponseSerializerErrorKey = @"JSONResponseSerializerErrorKey";

@interface OTJSONResponseSerializer : AFJSONResponseSerializer

@end
