//
//  OTMyEntouragesFilterDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTMyEntouragesFilter.h"

@protocol OTMyEntouragesFilterDelegate <NSObject>

- (void)filterChanged:(OTMyEntouragesFilter *)filter;

@end
