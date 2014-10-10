//
//  OTMenuItem.h
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMenuItem : NSObject

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *segueIdentifier;

/**************************************************************************************************/
#pragma mark - Birth and Death

- (instancetype)initWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier;

@end
