//
//  OTMenuItem.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuItem.h"

@implementation OTMenuItem

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName segueIdentifier:(NSString *)segueIdentifier
{
    self = [super init];
    if (self) {
        self.title = title;
        self.iconName = iconName;
        self.segueIdentifier = segueIdentifier;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName url:(NSString *)url {
    self = [super init];
    if (self) {
        self.title = title;
        self.iconName = iconName;
        self.url = url;
    }
    return self;
}

@end
