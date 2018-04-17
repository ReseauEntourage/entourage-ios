//
//  OTJSONResponseSerializer.h
//  entourage
//
//  Created by Ciprian Habuc on 30/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>

static NSString * const JSONResponseSerializerFullKey = @"JSONResponseSerializerFullKey";
static NSString * const JSONResponseSerializerFullDictKey = @"JSONResponseSerializerFullDictKey";

@interface OTJSONResponseSerializer : AFJSONResponseSerializer

@end
