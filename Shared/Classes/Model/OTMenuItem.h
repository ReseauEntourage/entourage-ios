//
//  OTMenuItem.h
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *segueIdentifier;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, readwrite) NSInteger tag;

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName segueIdentifier:(NSString *)segueIdentifier;
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName identifier:(NSString *)identifier;
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName;

@end
