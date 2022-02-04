//
//  OTAboutItem.m
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 Entourage. All rights reserved.
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

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url icon:(NSString *)icon
{
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
        self.icon = icon;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.title = title;
        self.identifier = identifier;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              segueIdentifier:(NSString *)segueIdentifier
{
    self = [super init];
    if (self) {
        self.title = title;
        self.segueIdentifier = segueIdentifier;
    }
    return self;
}

@end
