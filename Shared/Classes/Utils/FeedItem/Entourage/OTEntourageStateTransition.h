//
//  OTEntourageStateFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTStateTransitionDelegate.h"
#import "OTEntourageFactory.h"

@interface OTEntourageStateTransition : OTEntourageFactory<OTStateTransitionDelegate>
@end
