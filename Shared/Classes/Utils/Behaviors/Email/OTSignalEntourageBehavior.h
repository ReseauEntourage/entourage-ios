//
//  OTSignalEntourageBehavior.h
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourage.h"

@interface OTSignalEntourageBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)sendMailFor:(OTEntourage *)entourage;
- (void)sendPromoteEventMailFor:(OTEntourage *)entourage;

@end
