//
//  OTSignalEntourageBehavior.h
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourage.h"

@interface OTSignalEntourageBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)sendMailFor:(OTEntourage *)entourage;

@end
