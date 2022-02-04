//
//  OTRoleTag.m
//  pfp
//
//  Created by Grégoire Clermont on 06/02/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTRoleTag.h"
#import "OTAppConfiguration.h"

@implementation OTRoleTag {
    NSString *name;
    NSString *title;
    UIColor *color;
    BOOL visible;
}

- (instancetype)initWithName:(NSString *)name {
    if (!name) return nil;
    
    OTRoleTag *cachedInstance = [self.class sharedCache][name];
    if (cachedInstance) return cachedInstance;
    
    self = [super init];
    if (!self) return nil;
    
    NSDictionary *config = OTAppConfiguration.community[@"roles"][name];

    self->name = name;

    if (config == nil) {
        self->visible = NO;
    }
    else if (config[@"visible"] == nil) {
        self->visible = YES;
    }
    else {
        self->visible = config[@"visible"];
    }

    self->title = config[@"title"];
    if (self->title == nil) {
        self->title = name;
        self->visible = NO;
    }

    SEL colorSelector = NSSelectorFromString(config[@"color"]);
    if ([UIColor respondsToSelector:colorSelector]) {
        self->color = [UIColor performSelector:colorSelector];
    } else {
        self->color = UIColor.grayColor;
        self->visible = NO;
    }

    [[self.class sharedCache] setValue:(OTRoleTag *)self forKey:name];
    
    return self;
}

- (NSString *)name {
    return name;
}

- (NSString *)title {
    return title;
}

- (UIColor *)color {
    return color;
}

- (BOOL)visible {
    return visible;
}

+ (NSDictionary<NSString *, OTRoleTag *> *)sharedCache {
    static NSMutableDictionary<NSString *, OTRoleTag *> *sharedCache;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedCache = [NSMutableDictionary new];
    });
    return sharedCache;
}

@end
