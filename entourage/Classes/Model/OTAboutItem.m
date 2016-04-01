//
//  OTAboutItem.m
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAboutItem.h"

@implementation OTAboutItem

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url
{
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
    }
    return self;
}

@end
