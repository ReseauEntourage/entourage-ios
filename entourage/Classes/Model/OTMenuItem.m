//
//  OTMenuItem.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuItem.h"

@implementation OTMenuItem

/**************************************************************************************************/
#pragma mark - Birth and Death

/**
 * Init OTMenuItem with title and segueIdentifier
 *
 * @param title
 * The title to display in menu
 *
 * @param segueIdentifier
 * The segueIdentifier corresponding to Main.storyboard to naviguate in different items menu
 *
 * @return OTMenuItem
 * The new instance.
 */
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName segueIdentifier:(NSString *)segueIdentifier
{
    self = [super init];
    if (self)
    {
        _title = title;
        _iconName = iconName;
        _segueIdentifier = segueIdentifier;
    }
    return self;
}

@end
